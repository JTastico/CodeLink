//
//  PublicationDetailView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

// MARK: - Color Palette Extension
extension Color {
    static let darkBlue = Color(red: 0.1, green: 0.2, blue: 0.4)
    static let mediumBlue = Color(red: 0.2, green: 0.3, blue: 0.5)
    static let lightBlue = Color(red: 0.4, green: 0.6, blue: 0.8)
    static let skyBlue = Color(red: 0.5, green: 0.7, blue: 0.9)
    static let softWhite = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.1)
}

// MARK: - Comment List View
struct CommentListView: View {
    @ObservedObject var viewModel: CommentsViewModel
    @Binding var replyingTo: Comment?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .foregroundColor(.lightBlue)
                    .font(.title3)
                
                Text("Comentarios")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.softWhite)
                
                Spacer()
                
                Text("\(viewModel.commentThreads.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.lightBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.darkBlue)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 8)
            
            if viewModel.commentThreads.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "message.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.mediumBlue)
                    
                    Text("Aún no hay comentarios")
                        .font(.headline)
                        .foregroundColor(.softWhite)
                    
                    Text("¡Sé el primero en comentar!")
                        .font(.subheadline)
                        .foregroundColor(.lightBlue)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.darkBlue.opacity(0.3))
                        .stroke(Color.mediumBlue.opacity(0.5), lineWidth: 1)
                )
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.commentThreads) { thread in
                        VStack(alignment: .leading, spacing: 12) {
                            CommentRowView(comment: thread.parent, isReply: false, replyingTo: $replyingTo)
                            
                            if !thread.replies.isEmpty {
                                VStack(spacing: 8) {
                                    ForEach(thread.replies) { reply in
                                        CommentRowView(comment: reply, isReply: true, replyingTo: $replyingTo)
                                    }
                                }
                                .padding(.leading, 20)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.darkBlue.opacity(0.4))
                                .stroke(Color.mediumBlue.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Comment Row View
struct CommentRowView: View {
    let comment: Comment
    let isReply: Bool
    @Binding var replyingTo: Comment?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.lightBlue, .skyBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isReply ? 28 : 32, height: isReply ? 28 : 32)
                    .overlay(
                        Text(String(comment.authorUsername.prefix(1)).uppercased())
                            .font(.system(size: isReply ? 12 : 14, weight: .semibold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(comment.authorUsername)
                        .font(isReply ? .caption : .subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.softWhite)
                    
                    Text(comment.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.lightBlue)
                }
                
                Spacer()
                
                if isReply {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.caption2)
                        .foregroundColor(.mediumBlue)
                }
            }
            
            Text(comment.text)
                .font(isReply ? .callout : .body)
                .foregroundColor(.softWhite)

            if !isReply {
                HStack {
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
                        .foregroundColor(.lightBlue.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.darkBlue.opacity(0.6))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.lightBlue.opacity(0.3), lineWidth: 0.5)
                                )
                        )
                    }

                    Spacer()
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Main Publication Detail View
struct PublicationDetailView: View {
    let publication: Publication
    let currentUser: User?
    
    @StateObject private var viewModel: CommentsViewModel
    @State private var newCommentText: String = ""
    @State private var replyingTo: Comment? = nil
    private let publicationService = PublicationService()

    init(publication: Publication, currentUser: User?) {
        self.publication = publication
        self.currentUser = currentUser
        _viewModel = StateObject(wrappedValue: CommentsViewModel(publicationId: publication.id))
    }
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        publicationHeader
                        publicationDescription
                        elegantDivider
                        CommentListView(viewModel: viewModel, replyingTo: $replyingTo)
                    }
                    .padding(20)
                }
                
                if currentUser != nil {
                    commentInputField
                }
            }
        }
        .navigationTitle(publication.status.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.darkBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var publicationHeader: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(LinearGradient(colors: [.lightBlue, .skyBlue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(publication.authorUsername.prefix(1)).uppercased())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
                .shadow(color: .lightBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(publication.authorUsername)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.softWhite)
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.lightBlue)
                    Text(publication.formattedDate)
                        .font(.caption)
                        .foregroundColor(.lightBlue)
                }
            }
            
            Spacer()
            statusBadge
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.darkBlue.opacity(0.6))
                .stroke(Color.mediumBlue.opacity(0.4), lineWidth: 1)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
    }

    private var statusBadge: some View {
        Text(publication.status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(LinearGradient(colors: [.lightBlue, .skyBlue], startPoint: .leading, endPoint: .trailing))
            )
            .shadow(color: .lightBlue.opacity(0.4), radius: 4, x: 0, y: 2)
    }

    private var publicationDescription: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Descripción")
                .font(.headline)
                .foregroundColor(.softWhite)
            Text(publication.description)
                .font(.body)
                .foregroundColor(.softWhite)
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.darkBlue.opacity(0.3))
                .stroke(Color.mediumBlue.opacity(0.2), lineWidth: 1)
        )
    }

    private var elegantDivider: some View {
        Rectangle()
            .fill(LinearGradient(colors: [.clear, .lightBlue, .clear], startPoint: .leading, endPoint: .trailing))
            .frame(height: 1)
            .padding(.vertical, 8)
    }

    private var commentInputField: some View {
        VStack(spacing: 0) {
            if let replying = replyingTo {
                HStack {
                    Text("Respondiendo a ") +
                    Text("@\(replying.authorUsername)").bold()
                    Spacer()
                    Button {
                        withAnimation {
                            replyingTo = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .font(.caption)
                .foregroundColor(.lightBlue)
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }

            HStack(spacing: 16) {
                if let user = currentUser {
                    Circle()
                        .fill(LinearGradient(colors: [.lightBlue, .skyBlue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text(String(user.username.prefix(1)).uppercased())
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        )
                }

                TextField(
                    replyingTo == nil ? "Escribe un comentario..." : "Escribe tu respuesta...",
                    text: $newCommentText,
                    axis: .vertical
                )
                .font(.body)
                .foregroundColor(.softWhite)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.darkBlue.opacity(0.6))
                        .stroke(Color.mediumBlue.opacity(0.4), lineWidth: 1)
                )
                .lineLimit(1...4)

                Button {
                    Task { await postComment() }
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .font(.title2)
                        .foregroundColor(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .mediumBlue : .lightBlue)
                        .scaleEffect(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.8 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: newCommentText.isEmpty)
                }
                .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(20)
            .background(
                Rectangle()
                    .fill(Color.darkBackground)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
            )
        }
    }

    private func postComment() async {
        guard let author = currentUser,
              !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let commentToPost = newCommentText
        let parentId = replyingTo?.id
        newCommentText = ""
        replyingTo = nil

        do {
            try await publicationService.addComment(text: commentToPost, to: publication, by: author, parentId: parentId)
        } catch {
            print("Error al postear comentario: \(error)")
            newCommentText = commentToPost
        }
    }
}
