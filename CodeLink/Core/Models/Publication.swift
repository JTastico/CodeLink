//
//  Publication.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import Foundation

struct Publication: Identifiable, Hashable, Codable {
    // Lo mismo para el 'id' de una publicación
    let id: UUID
    let author: User
    let title: String
    let body: String
    let votes: Int
    let comments: [Comment]
    
    // --- CORRECCIÓN ---
    // Hacemos lo mismo aquí: creamos un usuario de ejemplo completo localmente.
    static var sampleData: [Publication] {
        let sampleUser = User(id: "sampleUserID2", username: "johndoe", fullName: "John Doe", email: "john@doe.com", profilePictureURL: nil, field: "iOS Developer")
        
        return [
            Publication(id: UUID(), author: sampleUser, title: "¿Cómo centrar un `VStack` en SwiftUI?", body: "He intentado de todo...", votes: 42, comments: Comment.sampleData),
            Publication(id: UUID(), author: sampleUser, title: "Error de 'fatal error: unexpectedly found nil...'", body: "Sé que esto significa que un opcional es nil...", votes: 15, comments: []),
            Publication(id: UUID(), author: sampleUser, title: "¿Cuál es la mejor manera de manejar la concurrencia?", body: "Con los nuevos cambios en el modelo de actores...", votes: 123, comments: [])
        ]
    }
}
