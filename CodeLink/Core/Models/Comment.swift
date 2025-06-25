//
//  Comment.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import Foundation

struct Comment: Identifiable, Hashable, Codable {
    // El 'id' de un comentario puede ser un UUID porque no lo guardamos por separado en la DB
    let id: UUID
    let author: User
    let text: String
    
    // --- CORRECCIÓN ---
    // Creamos un usuario de ejemplo completo aquí mismo para nuestros datos de prueba.
    static var sampleData: [Comment] {
        let sampleUser = User(id: "sampleUserID1", username: "janedev", fullName: "Jane Dev", email: "jane@dev.com", profilePictureURL: nil, field: "Android Developer")
        
        return [
            Comment(id: UUID(), author: sampleUser, text: "¡Gran pregunta! Intenta invalidar el layout del CollectionView."),
            Comment(id: UUID(), author: sampleUser, text: "A mí me pasó lo mismo, la solución es usar un `GeometryReader`.")
        ]
    }
}
