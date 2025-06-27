//
//  Comment.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import Foundation

struct Comment: Identifiable, Codable, Hashable {
    // Usamos @DocumentID para que Firebase asigne la clave del documento a esta propiedad.
    // Opcional por si lo creamos en el cliente primero.
    var id: String = UUID().uuidString
    
    let publicationId: String
    let authorUid: String
    let authorUsername: String
    let text: String
    let createdAt: TimeInterval
    
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: createdAt)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
