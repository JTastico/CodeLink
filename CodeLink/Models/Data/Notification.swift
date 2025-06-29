//
//  Notification.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//

import Foundation

struct Notification: Identifiable, Codable {
    var id: String // Usamos el key de Firebase como ID
    let recipientUid: String
    let senderUid: String
    let senderUsername: String
    let type: String // e.g., "new_comment"
    let publicationId: String? // Opcional, si no todas las notificaciones están ligadas a una publicación
    let commentText: String? // Opcional, específico para el tipo new_comment
    let createdAt: TimeInterval
    var isRead: Bool // Para marcar si la notificación ha sido leída
}
