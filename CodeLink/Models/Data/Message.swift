//
//  Message.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//


import Foundation
import FirebaseFirestoreSwift // Para trabajar con Timestamp y document IDs

struct Message: Identifiable, Codable, Hashable {
    @DocumentID var id: String? // El ID del documento en Firestore
    let conversationId: String
    let senderUid: String
    let senderUsername: String
    let recipientUid: String
    let text: String
    let createdAt: Date // Usaremos Date para mejor manejo de tiempo
    var isRead: Bool

    // Propiedad calculada para el ID (si id es nil, usa un UUID temporal)
    var uid: String {
        id ?? UUID().uuidString
    }

    enum CodingKeys: String, CodingKey {
        case id
        case conversationId
        case senderUid
        case senderUsername
        case recipientUid
        case text
        case createdAt
        case isRead
    }
}
