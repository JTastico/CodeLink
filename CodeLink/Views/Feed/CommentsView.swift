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
    
    @State private var isAnimating = false
    
    init(publication: Publication, currentUser: User) {
        self.publication = publication
        self.currentUser = currentUser
        _viewModel = StateObject(wrappedValue: CommentsViewModel(publicationId: publication.id))
    }
    
    // Función para iniciar las animaciones
    private func setupAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isAnimating = true
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Fondo principal
            Color.primaryGradient
                .ignoresSafeArea()
                .opacity(isAnimating ? 1.0 : 0.8)
                .animation(.easeInOut(duration: 1.5), value: isAnimating)
            
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
                            .glassCard(cornerRadius: 16)
                            .scaleEffect(isAnimating ? 1.01 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
                
                // Campo de entrada mejorado
                inputSection
            }
        }
        .onAppear {
            setupAnimations()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Comentarios")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryTextColor)
                
                Spacer()
                
                Text("\(viewModel.commentThreads.count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.accentBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.glassMorphism)
                            .overlay(
                                Capsule()
                                    .stroke(Color.accentBlue.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .glassCard(cornerRadius: 0)
            .scaleEffect(isAnimating ? 1.01 : 1.0)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.accentBlue.opacity(0.6), Color.vibrantBlue.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .opacity(isAnimating ? 0.8 : 0.4)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.accentBlue.opacity(0.6), Color.vibrantBlue.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .opacity(isAnimating ? 0.8 : 0.4)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
            
            VStack(alignment: .leading, spacing: 12) {
                // Indicador de respuesta
                if let replyingToComment = replyingTo {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .foregroundColor(Color.accentBlue)
                            .font(.caption)
                        
                        Text("Respondiendo a")
                            .font(.caption)
                            .foregroundColor(Color.primaryTextColor.opacity(0.7))
                        
                        Text("@\(replyingToComment.authorUsername)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.accentBlue)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                replyingTo = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.primaryTextColor.opacity(0.6))
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.glassMorphism)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.accentBlue.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .scaleEffect(isAnimating ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                // Campo de texto
                HStack(spacing: 16) {
                    TextField(
                        replyingTo == nil ? "Escribe un comentario..." : "Escribe tu respuesta...",
                        text: $newCommentText,
                        axis: .vertical
                    )
                    .textFieldStyle(.plain)
                    .foregroundColor(Color.primaryTextColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.glassMorphism)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isTextFieldFocused ? Color.accentBlue : Color.primaryTextColor.opacity(0.2), lineWidth: 1.5)
                            )
                    )
                    .focused($isTextFieldFocused)
                    .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                    
                    Button {
                        Task { await postComment() }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.primaryTextColor)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                ? [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]
                                                : [Color.accentBlue, Color.vibrantBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(
                                        color: newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                            ? .clear
                                            : Color.accentBlue.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            )
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .scaleEffect(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.9 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: newCommentText.isEmpty)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Color.accentGradient
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
    @State private var isAnimating = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar corregido
            AvatarView(
                imageURL: comment.profileImageURL,
                size: 36
            )
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(comment.username)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.accentBlue)

                    Text("·")
                        .foregroundColor(Color.secondaryTextColor)

                    Text(comment.formattedDate)
                        .font(.caption)
                        .foregroundColor(Color.secondaryTextColor)

                    Spacer()
                }

                Text(comment.text)
                    .font(.system(size: 15))
                    .foregroundColor(Color.primaryTextColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)

                Button(action: {
                    replyingTo = comment
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrowshape.turn.up.left")
                            .font(.caption2)
                        Text("Responder")
                            .font(.caption)
                    }
                    .foregroundColor(Color.accentBlue.opacity(0.8))
                    .padding(.top, 4)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(.leading, isReply ? 8 : 0)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                isAnimating = true
            }
        }
    }
}
