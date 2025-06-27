//
//  Publication.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import Foundation

struct Publication: Identifiable, Hashable, Codable {
    var id: String
    
    let authorUid: String
    var authorUsername: String
    
    var description: String
    var imageURL: String?
    
    let createdAt: TimeInterval
    
    var status: PublicationStatus
    
    // Nos aseguramos de que 'likes' siempre tenga un valor por defecto.
    var likes: Int = 0
    
    // Propiedad para formatear la fecha.
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: createdAt)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
