//
//  ConversationsListView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//

import SwiftUI

struct ConversationsListView: View {
    @ObservedObject var authService: AuthService
    @StateObject var viewModel: ConversationsViewModel

    // Nuevo estado para controlar la presentación de la hoja de búsqueda de usuarios
    @State private var showingUserSearchSheet = false
    // Nuevo estado para almacenar el usuario seleccionado para un nuevo chat
    @State private var selectedUserForNewChat: User?
    // Nuevo estado para controlar la navegación programática a ChatView
    @State private var navigateToNewChat = false

    init(authService: AuthService) {
        self.authService = authService
        _viewModel = StateObject(wrappedValue: ConversationsViewModel(authService: authService))
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando Conversaciones...")
                } else if viewModel.conversations.isEmpty {
                    Text("No tienes conversaciones. ¡Comienza una!")
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.conversations) { conversation in
                        NavigationLink(destination: ChatView(authService: authService, conversation: conversation)) {
                            ConversationRowView(conversation: conversation, currentUserId: authService.appUser?.id ?? "")
                        }
                    }
                }
            }
            .navigationTitle("Mensajes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingUserSearchSheet = true // Mostrar la hoja de búsqueda de usuarios
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            // Hoja modal para buscar usuarios
            .sheet(isPresented: $showingUserSearchSheet) {
                // CORRECCIÓN: Pasar 'authService' primero
                UserSearchView(authService: authService, onUserSelected: { user in
                    selectedUserForNewChat = user // Guarda el usuario seleccionado
                    showingUserSearchSheet = false // Cierra la hoja
                    navigateToNewChat = true      // Activa la navegación al ChatView
                })
            }
            // Link de navegación oculto que se activa programáticamente
            .background(
                NavigationLink(
                    destination: ChatView(authService: authService, recipientUser: selectedUserForNewChat),
                    isActive: $navigateToNewChat,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
    }
}

// MARK: - Sub-Vista para cada fila de conversación

struct ConversationRowView: View {
    let conversation: Conversation
    let currentUserId: String
    @State private var otherParticipantUsername: String = "..."
    @State private var otherParticipantProfilePictureURL: String?
    
    @ObservedObject var authService = AuthService()
    private let messageService = MessageService()

    var body: some View {
        HStack {
            // Imagen de perfil
            if let urlString = otherParticipantProfilePictureURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else if phase.error != nil {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .frame(width: 50, height: 50)
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading) {
                Text(otherParticipantUsername)
                    .font(.headline)

                if let lastMessage = conversation.lastMessageText {
                    Text(lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(conversation.lastMessageTimestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            fetchOtherParticipantDetails()
        }
    }

    private func fetchOtherParticipantDetails() {
        let otherParticipantUid = conversation.participantUids.first(where: { $0 != currentUserId }) ?? ""
        if !otherParticipantUid.isEmpty {
            messageService.fetchUser(uid: otherParticipantUid) { user in
                if let user = user {
                    self.otherParticipantUsername = user.username
                    self.otherParticipantProfilePictureURL = user.profilePictureURL
                } else {
                    self.otherParticipantUsername = "Usuario Desconocido"
                }
            }
        }
    }
}
