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
    
    // --- FUNCIÓN PARA LEER PUBLICACIONES ---
    func listenForPublications(completion: @escaping ([Publication]) -> Void) -> DatabaseHandle {
        let publicationsRef = dbRef.child("publications")
        
        let handle = publicationsRef.observe(.value) { snapshot, _ in
            guard let dataSnapshot = snapshot as? DataSnapshot else { return }

            var publications: [Publication] = []

            for child in dataSnapshot.children.allObjects as? [DataSnapshot] ?? [] {
                if let publicationData = child.value as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: publicationData)
                        let publication = try JSONDecoder().decode(Publication.self, from: jsonData)
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

    private func uploadPublicationImage(_ imageData: Data) async throws -> URL {
        let imageId = UUID().uuidString
        let imageRef = storageRef.child("publication_images/\(imageId).jpg")

        let _ = try await imageRef.putDataAsync(imageData)
        let downloadURL = try await imageRef.downloadURL()
        return downloadURL
    }

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
            status: status
        )

        do {
            let data = try JSONEncoder().encode(newPublication)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            try await publicationRef.setValue(json)
        } catch {
            throw error
        }
    }
}
