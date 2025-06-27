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
    
    var likes: Int
    var commentCount: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decodifica todos los campos obligatorios normalmente.
        id = try container.decode(String.self, forKey: .id)
        authorUid = try container.decode(String.self, forKey: .authorUid)
        authorUsername = try container.decode(String.self, forKey: .authorUsername)
        description = try container.decode(String.self, forKey: .description)
        createdAt = try container.decode(TimeInterval.self, forKey: .createdAt)
        status = try container.decode(PublicationStatus.self, forKey: .status)
        
        likes = try container.decodeIfPresent(Int.self, forKey: .likes) ?? 0
        commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount) ?? 0
        
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
    }
    

    init(id: String, authorUid: String, authorUsername: String, description: String, imageURL: String?, createdAt: TimeInterval, status: PublicationStatus, likes: Int = 0, commentCount: Int = 0) {
        self.id = id
        self.authorUid = authorUid
        self.authorUsername = authorUsername
        self.description = description
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.status = status
        self.likes = likes
        self.commentCount = commentCount
    }
    
    // Propiedad para formatear la fecha (sin cambios).
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: createdAt)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
