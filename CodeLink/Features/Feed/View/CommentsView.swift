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
    @State private var replyingTo: Comment?
    
    // Paleta de colores personalizada
    private let darkBlue = Color(red: 0.1, green: 0.15, blue: 0.25)
    private let lightBlue = Color(red: 0.4, green: 0.7, blue: 1.0)
    private let accentBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    private let softBlack = Color(red: 0.05, green: 0.05, blue: 0.1)
    
    init(publication: Publication, currentUser: User) {
        self.publication = publication
        self.currentUser = currentUser
        _viewModel = StateObject(wrappedValue: CommentsViewModel(publicationId: publication.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header mejorado
            headerSection
            
            // Lista de comentarios
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.commentThreads) { thread in
                        VStack(alignment: .leading, spacing: 12) {
                            // Comentario padre
                            CommentRow(
                                comment: thread.parent,
                                replyingTo: $replyingTo,
                                isReply: false
                            )
                            
                            // Respuestas
                            ForEach(thread.replies) { reply in
                                CommentRow(
                                    comment: reply,
                                    replyingTo: $replyingTo,
                                    isReply: true
                                )
                                .padding(.leading, 24)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(darkBlue.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(lightBlue.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .background(softBlack)
            
            // Campo de entrada mejorado
            inputSection
        }
        .background(softBlack)
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Comentarios")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.commentThreads.count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(lightBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(darkBlue)
                            .overlay(
                                Capsule()
                                    .stroke(lightBlue.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [darkBlue, darkBlue.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [lightBlue.opacity(0.6), accentBlue.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [lightBlue.opacity(0.4), accentBlue.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
            
            VStack(alignment: .leading, spacing: 12) {
                // Indicador de respuesta
                if let replyingToComment = replyingTo {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .foregroundColor(lightBlue)
                            .font(.caption)
                        
                        Text("Respondiendo a")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("@\(replyingToComment.authorUsername)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(lightBlue)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                replyingTo = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(darkBlue.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(lightBlue.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Campo de texto
                HStack(spacing: 16) {
                    TextField(
                        replyingTo == nil ? "Escribe un comentario..." : "Escribe tu respuesta...",
                        text: $newCommentText,
                        axis: .vertical
                    )
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(darkBlue.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isTextFieldFocused ? lightBlue : Color.white.opacity(0.2), lineWidth: 1.5)
                            )
                    )
                    .focused($isTextFieldFocused)
                    .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                    
                    Button {
                        Task { await postComment() }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                ? [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]
                                                : [lightBlue, accentBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(
                                        color: newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                            ? .clear
                                            : lightBlue.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            )
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .scaleEffect(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.9 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: newCommentText.isEmpty)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [darkBlue.opacity(0.9), softBlack],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    private func postComment() async {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let commentToPost = newCommentText
        let parentId = replyingTo?.id
        
        withAnimation(.easeInOut(duration: 0.3)) {
            newCommentText = ""
            replyingTo = nil
        }
        isTextFieldFocused = false
        
        do {
            try await publicationService.addComment(text: commentToPost, to: publication, by: currentUser, parentId: parentId)
        } catch {
            print("Error al postear comentario: \(error)")
            newCommentText = commentToPost
        }
    }
}

// MARK: - CommentRow Mejorado
struct CommentRow: View {
    let comment: Comment
    @Binding var replyingTo: Comment?
    let isReply: Bool
    
    // Paleta de colores
    private let lightBlue = Color(red: 0.4, green: 0.7, blue: 1.0)
    private let accentBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    private let darkBlue = Color(red: 0.1, green: 0.15, blue: 0.25)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header del comentario
            HStack(alignment: .center, spacing: 8) {
                // Avatar placeholder
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [lightBlue, accentBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isReply ? 28 : 32, height: isReply ? 28 : 32)
                    .overlay(
                        Text(String(comment.authorUsername.prefix(1)).uppercased())
                            .font(.system(size: isReply ? 12 : 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(comment.authorUsername)
                        .font(isReply ? .caption : .subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(comment.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                if isReply {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .font(.caption2)
                        .foregroundColor(lightBlue.opacity(0.7))
                }
            }
            
            // Contenido del comentario
            Text(comment.text)
                .font(isReply ? .caption : .callout)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            // Botón de responder
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    replyingTo = comment
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrowshape.turn.up.left")
                        .font(.caption2)
                    Text("Responder")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(lightBlue.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(darkBlue.opacity(0.6))
                        .overlay(
                            Capsule()
                                .stroke(lightBlue.opacity(0.3), lineWidth: 0.5)
                        )
                )
            }
            .padding(.top, 4)
        }
    }
}
