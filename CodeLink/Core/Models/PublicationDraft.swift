//
//  PublicationDraft.swift
//  CodeLink
//
//  Created by Jamil Turpo on 27/06/25.
//


import Foundation
import SwiftData

@Model
final class PublicationDraft {
    @Attribute(.unique) var id: UUID
    var authorUid: String
    
    var draftDescription: String
    var status: PublicationStatus
    var createdAt: Date
    init(description: String, status: PublicationStatus, authorUid: String) {
        self.id = UUID()
        self.draftDescription = description
        self.status = status
        self.createdAt = Date()
        self.authorUid = authorUid
    }
}
