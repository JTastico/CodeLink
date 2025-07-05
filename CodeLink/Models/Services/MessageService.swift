//
//  MessageService.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//


import Foundation
import Firebase
import FirebaseFirestore

class MessageService {
    private let db = Firestore.firestore()

    // MARK: - Enviar Mensajes

    /// Envía un mensaje a una conversación existente o crea una nueva si no existe.
    func sendMessage(text: String, sender: User, recipient: User, completion: @escaping (Error?) -> Void) {
        let participantUids = [sender.id, recipient.id].sorted() // Ordenar para un ID de conversación consistente
        
        // Buscar o crear la conversación
        db.collection("conversations")
            .whereField("participantUids", isEqualTo: participantUids)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error al buscar conversación: \(error.localizedDescription)")
                    completion(error)
                    return
                }

                if let document = querySnapshot?.documents.first {
                    // Conversación existente
                    let conversationId = document.documentID
                    self.addMessageToConversation(conversationId: conversationId, text: text, sender: sender, recipient: recipient, completion: completion)
                } else {
                    // Crear nueva conversación
                    self.createNewConversation(participantUids: participantUids, participantUsernames: [sender.username, recipient.username], initialMessageText: text, sender: sender, recipient: recipient, completion: completion)
                }
            }
    }

    private func createNewConversation(participantUids: [String], participantUsernames: [String], initialMessageText: String, sender: User, recipient: User, completion: @escaping (Error?) -> Void) {
        let newConversationRef = db.collection("conversations").document()
        let newConversation = Conversation(
            id: newConversationRef.documentID,
            participantUids: participantUids,
            participantUsernames: participantUsernames,
            lastMessageText: initialMessageText,
            lastMessageTimestamp: Date(),
            unreadCount: 0 // Se gestionaría externamente o con una función de Firebase
        )

        do {
            try newConversationRef.setData(from: newConversation) { error in
                if let error = error {
                    print("Error al crear nueva conversación: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                // Añadir el mensaje inicial a la nueva conversación
                self.addMessageToConversation(conversationId: newConversationRef.documentID, text: initialMessageText, sender: sender, recipient: recipient, completion: completion)
            }
        } catch {
            print("Error al codificar la conversación: \(error.localizedDescription)")
            completion(error)
        }
    }

    private func addMessageToConversation(conversationId: String, text: String, sender: User, recipient: User, completion: @escaping (Error?) -> Void) {
        let newMessageRef = db.collection("conversations").document(conversationId).collection("messages").document()
        let newMessage = Message(
            id: newMessageRef.documentID,
            conversationId: conversationId,
            senderUid: sender.id,
            senderUsername: sender.username,
            recipientUid: recipient.id,
            text: text,
            createdAt: Date(),
            isRead: false
        )

        do {
            try newMessageRef.setData(from: newMessage) { error in
                if let error = error {
                    print("Error al añadir mensaje: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                // Actualizar lastMessage y lastMessageTimestamp en la conversación
                self.db.collection("conversations").document(conversationId).updateData([
                    "lastMessageText": text,
                    "lastMessageTimestamp": FieldValue.serverTimestamp() // Usa serverTimestamp para consistencia
                ]) { err in
                    if let err = err {
                        print("Error al actualizar conversación: \(err.localizedDescription)")
                    }
                    completion(nil) // El mensaje se envió correctamente
                }
            }
        } catch {
            print("Error al codificar el mensaje: \(error.localizedDescription)")
            completion(error)
        }
    }

    // MARK: - Escuchar Conversaciones

    /// Escucha los cambios en las conversaciones de un usuario específico.
    func listenForConversations(forUserId userId: String, completion: @escaping ([Conversation]) -> Void) -> ListenerRegistration {
        return db.collection("conversations")
            .whereField("participantUids", arrayContains: userId)
            .order(by: "lastMessageTimestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error al escuchar conversaciones: \(error?.localizedDescription ?? "Desconocido")")
                    return
                }

                let conversations = documents.compactMap { document -> Conversation? in
                    try? document.data(as: Conversation.self)
                }
                completion(conversations)
            }
    }

    // MARK: - Escuchar Mensajes en una Conversación

    /// Escucha los cambios en los mensajes de una conversación específica.
    func listenForMessages(inConversationId conversationId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        return db.collection("conversations").document(conversationId).collection("messages")
            .order(by: "createdAt")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error al escuchar mensajes: \(error?.localizedDescription ?? "Desconocido")")
                    return
                }

                let messages = documents.compactMap { document -> Message? in
                    try? document.data(as: Message.self)
                }
                completion(messages)
            }
    }

    // MARK: - Marcar Mensajes como Leídos

    /// Marca un mensaje como leído.
    func markMessageAsRead(conversationId: String, messageId: String, completion: @escaping (Error?) -> Void) {
        db.collection("conversations").document(conversationId).collection("messages").document(messageId).updateData([
            "isRead": true
        ]) { error in
            completion(error)
        }
    }

    // MARK: - Obtener Usuario por UID (Necesario para detalles en la UI)
    func fetchUser(uid: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(uid).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let document = documentSnapshot, document.exists else {
                completion(nil)
                return
            }
            let user = try? document.data(as: User.self)
            completion(user)
        }
    }
}
