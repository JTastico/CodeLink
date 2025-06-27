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
    
    // --- CREAR PUBLICACIÓN ---
    func createPublication(description: String, status: PublicationStatus, imageData: Data?, author: User) async throws {
        var imageURL: URL? = nil
        
        if let imageData = imageData {
            imageURL = try await uploadPublicationImage(imageData)
        }
        
        let publicationRef = dbRef.child("publications").childByAutoId()
        let publicationId = publicationRef.key ?? UUID().uuidString
        
        let newPublication = Publication(
            id: publicationId,
            authorUid: author.id,
            authorUsername: author.username,
            description: description,
            imageURL: imageURL?.absoluteString,
            createdAt: Date().timeIntervalSince1970,
            status: status,
            likes: 0
        )
        
        let data = try JSONEncoder().encode(newPublication)
        let json = try JSONSerialization.jsonObject(with: data)
        try await publicationRef.setValue(json)
    }
    
    // --- ACTUALIZAR PUBLICACIÓN ---
    func updatePublication(_ publication: Publication) async throws {
        let publicationRef = dbRef.child("publications").child(publication.id)
        let data = try JSONEncoder().encode(publication)
        let json = try JSONSerialization.jsonObject(with: data)
        try await publicationRef.updateChildValues(json as! [AnyHashable : Any])
        print("Publicación actualizada exitosamente.")
    }
    
    // --- ELIMINAR PUBLICACIÓN ---
    func deletePublication(_ publication: Publication) async throws {
        let publicationRef = dbRef.child("publications").child(publication.id)
        try await publicationRef.removeValue()
        print("Publicación eliminada exitosamente.")
    }
    
    // --- LIKE / DISLIKE ---
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
    
    // --- ESCUCHAR PUBLICACIONES ---
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
    
    // --- DETENER ESCUCHA ---
    func removeListener(with handle: DatabaseHandle) {
        let publicationsRef = dbRef.child("publications")
        publicationsRef.removeObserver(withHandle: handle)
    }
    
    // --- SUBIR IMAGEN ---
    private func uploadPublicationImage(_ imageData: Data) async throws -> URL {
        let imageId = UUID().uuidString
        let imageRef = storageRef.child("publication_images/\(imageId).jpg")
        let _ = try await imageRef.putDataAsync(imageData)
        return try await imageRef.downloadURL()
    }
    
    // --- AÑADIR COMENTARIO ---
    func addComment(text: String, to publication: Publication, by author: User, parentId: String? = nil) async throws {
        let newComment = Comment(
            publicationId: publication.id,
            authorUid: author.id,
            authorUsername: author.username,
            text: text,
            createdAt: Date().timeIntervalSince1970,
            parentId: parentId // Guardamos el ID del padre
        )
        
        // La ruta para guardar no cambia, sigue siendo bajo el ID de la publicación.
        let commentRef = dbRef.child("comments").child(publication.id).childByAutoId()
        let commentData = try JSONEncoder().encode(newComment)
        let commentJson = try JSONSerialization.jsonObject(with: commentData)
        try await commentRef.setValue(commentJson)
        
        // Actualizamos el contador de comentarios de la publicación
        let publicationCommentsRef = dbRef.child("publications").child(publication.id).child("commentCount")
        try await publicationCommentsRef.runTransactionBlock { (currentData: MutableData) -> TransactionResult in
            var count = currentData.value as? Int ?? 0
            count += 1
            currentData.value = count
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    // --- ESCUCHAR COMENTARIOS ---
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
