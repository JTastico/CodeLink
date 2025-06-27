//
//  CommentsView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 26/06/25.
//


import SwiftUI

struct CommentsView: View {
    let publication: Publication
    let currentUser: User
    
    @StateObject private var viewModel: CommentsViewModel
    private let publicationService = PublicationService()
    
    @State private var newCommentText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    // --- NUEVO ESTADO PARA MANEJAR A QUIÉN RESPONDEMOS ---
    @State private var replyingTo: Comment?
    
    init(publication: Publication, currentUser: User) {
        self.publication = publication
        self.currentUser = currentUser
        _viewModel = StateObject(wrappedValue: CommentsViewModel(publicationId: publication.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Comentarios")
                .font(.headline)
                .padding()
            
            Divider()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    // --- RECORREMOS LOS HILOS DE COMENTARIOS ---
                    ForEach(viewModel.commentThreads) { thread in
                        // Mostramos el comentario padre
                        CommentRow(comment: thread.parent, replyingTo: $replyingTo)
                        
                        // Mostramos las respuestas con una indentación
                        ForEach(thread.replies) { reply in
                            CommentRow(comment: reply, replyingTo: $replyingTo)
                                .padding(.leading, 30) // Indentación para las respuestas
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // --- CAMPO DE TEXTO ACTUALIZADO ---
            VStack(alignment: .leading, spacing: 4) {
                // Si estamos respondiendo a alguien, lo indicamos
                if let replyingToComment = replyingTo {
                    HStack {
                        Text("Respondiendo a @\(replyingToComment.authorUsername)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button {
                            replyingTo = nil // Botón para cancelar la respuesta
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    TextField(replyingTo == nil ? "Escribe un comentario..." : "Escribe tu respuesta...", text: $newCommentText)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                        .focused($isTextFieldFocused)
                    
                    Button {
                        Task { await postComment() }
                    } label: {
                        Image(systemName: "paperplane.circle.fill")
                            .font(.title)
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding()
        }
    }
    
    private func postComment() async {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let commentToPost = newCommentText
        let parentId = replyingTo?.id // Obtenemos el ID del padre si estamos respondiendo
        
        newCommentText = ""
        replyingTo = nil
        isTextFieldFocused = false
        
        do {
            try await publicationService.addComment(text: commentToPost, to: publication, by: currentUser, parentId: parentId)
        } catch {
            print("Error al postear comentario: \(error)")
            newCommentText = commentToPost
        }
    }
}

// --- NUEVA SUB-VISTA PARA CADA COMENTARIO ---
struct CommentRow: View {
    let comment: Comment
    @Binding var replyingTo: Comment?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.authorUsername).font(.caption.bold())
                Spacer()
                Text(comment.formattedDate).font(.caption2).foregroundStyle(.secondary)
            }
            
            Text(comment.text).font(.callout)
            
            Button {
                replyingTo = comment // Al presionar, establecemos a quién respondemos
            } label: {
                Text("Responder")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .tint(.secondary)
            .padding(.top, 2)
        }
    }
}
