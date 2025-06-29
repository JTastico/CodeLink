//
//  PublicationService.swift
//  CodeLink
//
//  Created by Jamil Turpo on 25/06/25.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

class PublicationService: ObservableObject {
    
    private var dbRef: DatabaseReference = Database.database().reference()
    private var storageRef: StorageReference = Storage.storage().reference()
    
    // --- SUBIR IMAGEN (NUEVA FUNCIÓN PRIVADA) ---
    private func uploadPublicationImage(_ imageData: Data) async throws -> URL {
        let imageId = UUID().uuidString
        let imageRef = storageRef.child("publication_images/\(imageId).jpg")
        
        // Sube los datos de la imagen
        let _ = try await imageRef.putDataAsync(imageData)
        
        // Obtiene y devuelve la URL de descarga
        return try await imageRef.downloadURL()
    }
    
    // --- CREAR PUBLICACIÓN (ACTUALIZADO) ---
    func createPublication(description: String, status: PublicationStatus, imageData: Data?, author: User) async throws {
        var imageURLString: String? = nil
        
        // 1. Si se proporcionan datos de imagen, súbelos
        if let imageData = imageData {
            let imageURL = try await uploadPublicationImage(imageData)
            imageURLString = imageURL.absoluteString
        }
        
        let publicationRef = dbRef.child("publications").childByAutoId()
        let publicationId = publicationRef.key ?? UUID().uuidString
        
        // 2. Incluye la URL de la imagen en el nuevo objeto de publicación
        let newPublication = Publication(
            id: publicationId,
            authorUid: author.id,
            authorUsername: author.username,
            description: description,
            imageURL: imageURLString, // <- Aquí se guarda la URL
            createdAt: Date().timeIntervalSince1970,
            status: status,
            likes: 0,
            commentCount: 0 // Aseguramos que se inicialice
        )
        
        let data = try JSONEncoder().encode(newPublication)
        let json = try JSONSerialization.jsonObject(with: data)
        try await publicationRef.setValue(json)
    }
    
    // --- El resto del servicio no necesita cambios ---
    func updatePublication(_ publication: Publication) async throws {
        let publicationRef = dbRef.child("publications").child(publication.id)
        let data = try JSONEncoder().encode(publication)
        let json = try JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any] ?? [:]
        try await publicationRef.updateChildValues(json)
    }
    
    func deletePublication(_ publication: Publication) async throws {
        // Antes de eliminar la publicación, elimina la imagen asociada si existe
        if let imageUrlString = publication.imageURL, let imageUrl = URL(string: imageUrlString) {
            let imageRef = Storage.storage().reference(forURL: imageUrlString)
            try? await imageRef.delete()
        }
        
        let publicationRef = dbRef.child("publications").child(publication.id)
        try await publicationRef.removeValue()
    }
    
    func likePublication(publicationId: String, currentLikes: Int, shouldLike: Bool) {
        let likesRef = dbRef.child("publications").child(publicationId).child("likes")
        
        likesRef.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            var likes = currentData.value as? Int ?? currentLikes
            if shouldLike {
                likes += 1
            } else if likes > 0 {
                likes -= 1
            }
            currentData.value = likes
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    func listenForPublications(completion: @escaping ([Publication]) -> Void) -> DatabaseHandle {
        let publicationsRef = dbRef.child("publications")
        let handle = publicationsRef.observe(.value) { snapshot in
            var publications: [Publication] = []
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let publicationData = child.value as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: publicationData)
                        var publication = try JSONDecoder().decode(Publication.self, from: jsonData)
                        publication.id = child.key
                        publications.append(publication)
                    } catch {
                        print("Error al decodificar una publicación: \(error)")
                    }
                }
            }
            completion(publications.sorted(by: { $0.createdAt > $1.createdAt }))
        }
        return handle
    }
    
    func removeListener(with handle: DatabaseHandle) {
        let publicationsRef = dbRef.child("publications")
        publicationsRef.removeObserver(withHandle: handle)
    }
    
    func addComment(text: String, to publication: Publication, by author: User, parentId: String? = nil) async throws {
        let newComment = Comment(
            id: UUID().uuidString,
            username: author.username,
            profileImageURL: author.profilePictureURL,
            publicationId: publication.id,
            authorUid: author.id,
            authorUsername: author.username,
            text: text,
            createdAt: Date().timeIntervalSince1970,
            parentId: parentId
        )

        let commentRef = dbRef.child("comments").child(publication.id).childByAutoId()
        let commentData = try JSONEncoder().encode(newComment)
        let commentJson = try JSONSerialization.jsonObject(with: commentData)
        try await commentRef.setValue(commentJson)
        
        let publicationCommentsRef = dbRef.child("publications").child(publication.id).child("commentCount")
        try await publicationCommentsRef.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            var count = currentData.value as? Int ?? 0
            count += 1
            currentData.value = count
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    func listenForComments(for publicationId: String, completion: @escaping ([Comment]) -> Void) -> DatabaseHandle {
        let commentsRef = dbRef.child("comments").child(publicationId)
        
        let handle = commentsRef.observe(.value) { snapshot in
            var comments: [Comment] = []
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let commentData = child.value as? [String: Any] {
                    do {
                        var comment = try JSONDecoder().decode(Comment.self, from: JSONSerialization.data(withJSONObject: commentData))
                        comment.id = child.key
                        comments.append(comment)
                    } catch {
                        print("Error al decodificar un comentario: \(error)")
                    }
                }
            }
            completion(comments.sorted(by: { $0.createdAt < $1.createdAt }))
        }
        return handle
    }
}
