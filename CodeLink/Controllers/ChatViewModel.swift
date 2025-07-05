//
//  ChatViewModel.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//


import Foundation
import Combine
import Firebase

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var chatTitle: String = "Chat"
    
    private var messageService = MessageService()
    private var authService: AuthService
    private var conversation: Conversation? // La conversación actual si ya existe
    private var recipientUser: User? // El otro participante si es un chat nuevo
    private var messageListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthService, conversation: Conversation? = nil, recipientUser: User? = nil) {
        self.authService = authService
        self.conversation = conversation
        self.recipientUser = recipientUser
        
        setupChatTitle()
    }
    
    deinit {
        messageListener?.remove()
    }
    
    private func setupChatTitle() {
        if let conversation = conversation {
            // Si hay una conversación existente, busca el nombre del otro participante
            // CORRECCIÓN: Usar authService.appUser en lugar de authService.currentUser
            let otherParticipantUid = conversation.participantUids.first(where: { $0 != authService.appUser?.id }) ?? ""
            if let index = conversation.participantUids.firstIndex(of: otherParticipantUid) {
                self.chatTitle = conversation.participantUsernames[index]
            } else {
                self.chatTitle = "Conversación"
            }
        } else if let recipientUser = recipientUser {
            self.chatTitle = recipientUser.username
        }
    }

    func loadMessages() {
        guard let conversationId = conversation?.id else {
            // Si no hay conversationId, y tenemos un recipientUser, significa un chat nuevo.
            // Los mensajes se cargarán una vez se cree la conversación al enviar el primer mensaje.
            return
        }
        
        messageListener?.remove() // Remover listener anterior
        
        messageListener = messageService.listenForMessages(inConversationId: conversationId) { [weak self] fetchedMessages in
            DispatchQueue.main.async {
                self?.messages = fetchedMessages
            }
        }
    }
    
    func sendMessage(text: String) {
        // CORRECCIÓN: Usar authService.appUser en lugar de authService.currentUser
        guard let currentUser = authService.appUser else {
            print("Error: Usuario actual no autenticado.")
            return
        }
        
        var actualRecipient: User?
        if let conv = conversation {
            let otherUid = conv.participantUids.first(where: { $0 != currentUser.id }) ?? ""
            messageService.fetchUser(uid: otherUid) { [weak self] user in // Agregado [weak self]
                guard let self = self else { return } // Desenvuelto self para evitar warnings
                if let user = user {
                    self.performSendMessage(text: text, currentUser: currentUser, recipient: user)
                } else {
                    print("Error: No se pudo encontrar el usuario recipiente.")
                }
            }
        } else if let recUser = recipientUser {
            performSendMessage(text: text, currentUser: currentUser, recipient: recUser)
        } else {
            print("Error: No se encontró el recipiente para enviar el mensaje.")
        }
    }
    
    private func performSendMessage(text: String, currentUser: User, recipient: User) {
        messageService.sendMessage(text: text, sender: currentUser, recipient: recipient) { [weak self] error in
            guard let self = self else { return } // Desenvuelto self para evitar warnings
            if let error = error {
                print("Error al enviar mensaje: \(error.localizedDescription)")
                // Manejar error en la UI si es necesario
            } else {
                print("Mensaje enviado con éxito.")

            }
        }
    }
}
