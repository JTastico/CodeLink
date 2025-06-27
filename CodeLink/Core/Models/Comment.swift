//
//  Comment.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import Foundation

struct Comment: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    let publicationId: String
    let authorUid: String
    let authorUsername: String
    let text: String
    let createdAt: TimeInterval
    var parentId: String?
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: createdAt)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CommentThread: Identifiable, Hashable {
    var id: String { parent.id }
    let parent: Comment
    let replies: [Comment]
}
