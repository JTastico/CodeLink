//
//  Publication.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import Foundation

struct Publication: Identifiable, Hashable, Codable {
    // Usaremos un String para el ID para que coincida con la clave de Firebase.
    var id: String
    
    let authorUid: String
    var authorUsername: String
    
    var description: String
    var imageURL: String? // La URL de la imagen en Firebase Storage (opcional)
    
    // Usamos TimeInterval (un Double) para guardar la fecha, es compatible con Firebase.
    let createdAt: TimeInterval
    
    var status: PublicationStatus
    
    var likes: Int = 0
    // Podríamos añadir más campos después, como un array de IDs de comentarios.
    
    // --- LA PIEZA QUE FALTABA ---
    /// Propiedad computada para obtener la fecha formateada en un string legible.
    var formattedDate: String {
        // Convierte el TimeInterval a un objeto Date.
        let date = Date(timeIntervalSince1970: createdAt)
        
        // Usa un DateFormatter para darle el estilo que queremos.
        let formatter = DateFormatter()
        formatter.dateStyle = .short // "26/6/25"
        formatter.timeStyle = .short // "10:58 PM"
        
        // Devuelve el string final.
        return formatter.string(from: date)
    }
}
