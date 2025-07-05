//
//  Conversation.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//


import Foundation
import FirebaseFirestoreSwift // Para trabajar con Timestamp y document IDs

struct Conversation: Identifiable, Codable, Hashable {
    @DocumentID var id: String? // El ID del documento en Firestore
    let participantUids: [String] // IDs de los usuarios en la conversación
    let participantUsernames: [String] // Nombres de usuario de los participantes (para facilitar la UI)
    var lastMessageText: String?
    var lastMessageTimestamp: Date
    var unreadCount: Int // Número de mensajes no leídos para el usuario actual (podría ser calculado en el cliente o gestionado por una función de Firebase)

    // Propiedad calculada para el ID (si id es nil, usa un UUID temporal)
    var uid: String {
        id ?? UUID().uuidString
    }

    enum CodingKeys: String, CodingKey {
        case id
        case participantUids
        case participantUsernames
        case lastMessageText
        case lastMessageTimestamp
        case unreadCount
    }
}
