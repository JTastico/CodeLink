//
//  ConversationsViewModel.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//


import Foundation
import Combine
import Firebase

class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private var messageService = MessageService()
    private var authService: AuthService
    private var conversationListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthService) {
        self.authService = authService
        setupSubscribers()
    }

    deinit {
        conversationListener?.remove()
    }

    private func setupSubscribers() {
        // CORRECCIÓN: Usar authService.$appUser en lugar de authService.$userSession
        authService.$appUser
            // CORRECCIÓN: El parámetro de la closure ahora es 'appUser'
            .sink { [weak self] appUser in
                // CORRECCIÓN: Acceder al ID a través de appUser?.id
                if let uid = appUser?.id {
                    self?.loadConversations(forUserId: uid)
                } else {
                    self?.conversations = []
                    self?.conversationListener?.remove()
                }
            }
            .store(in: &cancellables)
    }

    func loadConversations(forUserId userId: String) {
        isLoading = true
        conversationListener?.remove()

        conversationListener = messageService.listenForConversations(forUserId: userId) { [weak self] fetchedConversations in
            DispatchQueue.main.async {
                self?.conversations = fetchedConversations
                self?.isLoading = false
            }
        }
    }
    
    // Función de ejemplo para iniciar un nuevo chat desde otro lugar (e.g., perfil de usuario)
    func startNewConversation(withUser user: User) {
        // CORRECCIÓN: Usar authService.appUser en lugar de authService.currentUser
        guard let currentUser = authService.appUser else {
            errorMessage = "Usuario actual no encontrado."
            return
        }
        
        // Simplemente navega a un ChatView vacío que luego se encargará de crear/encontrar la conversación
        // Este método es más bien conceptual para indicar dónde se iniciaría la lógica de un nuevo chat
        print("Intentando iniciar conversación con: \(user.username)")
        // La navegación y la creación real del chat se manejarán en la UI o en el ChatViewModel
    }
}
