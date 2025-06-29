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

    private func uploadPublicationImage(_ imageData: Data) async throws -> URL {
        let imageId = UUID().uuidString
        let imageRef = storageRef.child("publication_images/\(imageId).jpg")

        let _ = try await imageRef.putDataAsync(imageData)

        return try await imageRef.downloadURL()
    }

    func createPublication(description: String, status: PublicationStatus, imageData: Data?, author: User) async throws {
        var imageURLString: String? = nil

        if let imageData = imageData {
            let imageURL = try await uploadPublicationImage(imageData)
            imageURLString = imageURL.absoluteString
        }

        let publicationRef = dbRef.child("publications").childByAutoId()
        let publicationId = publicationRef.key ?? UUID().uuidString

        let newPublication = Publication(
            id: publicationId,
            authorUid: author.id,
            authorUsername: author.username,
            authorProfilePictureURL: author.profilePictureURL,
            description: description,
            imageURL: imageURLString,
            createdAt: Date().timeIntervalSince1970,
            status: status,
            likes: 0,
            commentCount: 0
        )

        let data = try JSONEncoder().encode(newPublication)
        let json = try JSONSerialization.jsonObject(with: data)
        try await publicationRef.setValue(json)
    }

    func updatePublication(_ publication: Publication) async throws {
        let publicationRef = dbRef.child("publications").child(publication.id)
        let data = try JSONEncoder().encode(publication)
        let json = try JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any] ?? [:]
        try await publicationRef.updateChildValues(json)
    }

    func deletePublication(_ publication: Publication) async throws {
        if let imageUrlString = publication.imageURL {
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

    // --- NUEVO MÉTODO AÑADIDO: Obtener Publicación por ID ---
    func getPublicationById(_ publicationId: String) async throws -> Publication? {
        let publicationRef = dbRef.child("publications").child(publicationId)
        let snapshot = try await publicationRef.getData() // Obtiene los datos una sola vez

        guard snapshot.exists(), let publicationData = snapshot.value as? [String: Any] else {
            return nil // No se encontró la publicación
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: publicationData)
            var publication = try JSONDecoder().decode(Publication.self, from: jsonData)
            publication.id = snapshot.key // Asegúrate de que el ID se establece desde la clave de Firebase
            return publication
        } catch {
            print("Error al decodificar la publicación por ID: \(error)")
            throw error // Relanza el error para que el llamador lo maneje
        }
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
            authorUid: publication.authorUid,
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

        // Lógica de notificación: Registra la notificación en la DB
        if author.id != publication.authorUid {
            let notificationRef = dbRef.child("notifications").childByAutoId()
            let notificationId = notificationRef.key ?? UUID().uuidString

            let notificationData: [String: Any] = [
                "id": notificationId,
                "recipientUid": publication.authorUid,
                "senderUid": author.id,
                "senderUsername": author.username,
                "type": "new_comment",
                "publicationId": publication.id,
                "commentText": text,
                "createdAt": Date().timeIntervalSince1970,
                "isRead": false
            ]
            try await notificationRef.setValue(notificationData)
            print("DEBUG: Notificación de nuevo comentario registrada para el usuario \(publication.authorUid)")
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
