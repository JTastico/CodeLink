//
//  CommentsViewModel.swift
//  CodeLink
//
//  Created by Jamil Turpo on 26/06/25.
//


import Foundation
import FirebaseDatabase

@MainActor
class CommentsViewModel: ObservableObject {
    // Publicamos los hilos de comentarios, no una lista plana.
    @Published var commentThreads: [CommentThread] = []
    
    private let publicationService = PublicationService()
    private var commentsListenerHandle: DatabaseHandle?
    private let publicationId: String
    
    init(publicationId: String) {
        self.publicationId = publicationId
        listenForComments()
    }
    
    deinit {
        if let handle = commentsListenerHandle {
            // Reutilizamos la función de 'PublicationService' porque la ruta no ha cambiado
            publicationService.removeListener(with: handle)
        }
    }
    
    func listenForComments() {
        commentsListenerHandle = publicationService.listenForComments(for: publicationId) { [weak self] allComments in
            // Cuando recibimos la lista de comentarios, llamamos a la función para organizarlos.
            self?.organizeCommentsIntoThreads(comments: allComments)
        }
    }
    
    // --- FUNCIÓN CLAVE PARA ORGANIZAR EN HILOS ---
    private func organizeCommentsIntoThreads(comments: [Comment]) {
        var threads: [CommentThread] = []
        var commentMap = [String: Comment]()
        
        // Creamos un mapa para fácil acceso
        for comment in comments {
            commentMap[comment.id] = comment
        }
        
        // 1. Filtramos los comentarios que son padres (no tienen parentId)
        let parentComments = comments.filter { $0.parentId == nil }
                                     .sorted(by: { $0.createdAt < $1.createdAt })
        
        // 2. Para cada comentario padre, buscamos sus respuestas
        for parent in parentComments {
            let replies = comments.filter { $0.parentId == parent.id }
                                  .sorted(by: { $0.createdAt < $1.createdAt })
            
            // 3. Creamos el hilo y lo añadimos a la lista
            let thread = CommentThread(parent: parent, replies: replies)
            threads.append(thread)
        }
        
        self.commentThreads = threads
    }
}
