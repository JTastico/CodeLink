//
//  ChatView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//


import SwiftUI

struct ChatView: View {
    @ObservedObject var authService: AuthService
    @StateObject var viewModel: ChatViewModel // Asumimos que crearás este ViewModel
    @State private var newMessageText: String = ""

    // Inicia con una conversación existente o con los UIDs para crear una nueva
    init(authService: AuthService, conversation: Conversation? = nil, recipientUser: User? = nil) {
        self.authService = authService
        _viewModel = StateObject(wrappedValue: ChatViewModel(authService: authService, conversation: conversation, recipientUser: recipientUser))
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        // CORRECCIÓN: Usar authService.appUser para comparar el ID del usuario actual
                        MessageBubble(message: message, isCurrentUser: message.senderUid == authService.appUser?.id)
                    }
                }
                .padding()
            }
            
            Divider()
            
            HStack {
                TextField("Escribe un mensaje...", text: $newMessageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                
                Button("Enviar") {
                    if !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.sendMessage(text: newMessageText)
                        newMessageText = ""
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle(viewModel.chatTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadMessages()
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: .leading) {
                Text(message.senderUsername)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(message.text)
                    .padding(10)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(10)
                
                Text(message.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .opacity(0.7)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
    }
}
