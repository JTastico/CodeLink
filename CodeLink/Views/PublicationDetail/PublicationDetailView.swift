//
//  PublicationDetailView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct CommentRowView: View {
    let comment: Comment
    let isReply: Bool
    @Binding var replyingTo: Comment?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Avatar del comentario (esto ya debería funcionar bien)
                AvatarView(imageURL: comment.profileImageURL, size: isReply ? 32 : 40)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(comment.authorUsername)
                            .font(.system(size: 14, weight: .semibold))
                        Text("· \(comment.formattedDate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(comment.text)
                        .font(.system(size: 15))
                }
                Spacer()
            }

            if !isReply {
                Button("Responder") {
                    withAnimation {
                        replyingTo = comment
                    }
                }
                .font(.caption.bold())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 4)
            }
        }
    }
}


struct PublicationDetailView: View {
    let publication: Publication
    let currentUser: User?
    
    @StateObject private var viewModel: CommentsViewModel
    @State private var newCommentText: String = ""
    @State private var replyingTo: Comment? = nil
    private let publicationService = PublicationService()

    @Environment(\.dismiss) private var dismiss

    init(publication: Publication, currentUser: User?) {
        self.publication = publication
        self.currentUser = currentUser
        _viewModel = StateObject(wrappedValue: CommentsViewModel(publicationId: publication.id))
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        publicationCard
                        commentsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
                if currentUser != nil {
                    commentInputField
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "chevron.left").font(.headline.weight(.bold)) }
                Spacer()
                VStack {
                    Text("Publicación").font(.headline.bold())
                    Text(publication.status.displayName).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding()
            Divider()
        }
        .background(Color(.systemBackground).ignoresSafeArea(edges: .top))
    }

    private var publicationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                // --- CAMBIO AQUÍ ---
                AvatarView(imageURL: publication.authorProfilePictureURL, size: 44)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(publication.authorUsername).font(.system(size: 16, weight: .semibold))
                    Text(publication.formattedDate).font(.system(size: 12)).foregroundColor(.secondary)
                }
                Spacer()
            }

            Text(publication.description)
                .font(.system(size: 15)).lineSpacing(4)
            
            if let imageURLString = publication.imageURL, let imageURL = URL(string: imageURLString) {
                AsyncImage(url: imageURL) { image in
                    image.resizable().aspectRatio(contentMode: .fit).cornerRadius(15)
                } placeholder: {
                    Rectangle().fill(Color(.systemGray5)).frame(height: 250).cornerRadius(15).overlay(ProgressView())
                }
                .padding(.vertical, 8)
            }
            
            Text(publication.status.displayName)
                .font(.caption.bold()).padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.blue.opacity(0.15)).foregroundColor(.blue).clipShape(Capsule())
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comentarios").font(.headline)
            
            if viewModel.commentThreads.isEmpty {
                Text("Sé el primero en comentar.").foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 20)
            } else {
                ForEach(viewModel.commentThreads) { thread in
                    VStack {
                        CommentRowView(comment: thread.parent, isReply: false, replyingTo: $replyingTo)
                        ForEach(thread.replies) { reply in
                            CommentRowView(comment: reply, isReply: true, replyingTo: $replyingTo).padding(.leading, 20)
                        }
                    }
                    if thread.id != viewModel.commentThreads.last?.id {
                        Divider().padding(.vertical, 8)
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
    
    private var commentInputField: some View {
        VStack(spacing: 0) {
            Divider()
            if let replying = replyingTo {
                HStack {
                    Text("Respondiendo a @\(replying.authorUsername)")
                    Spacer()
                    Button { withAnimation { replyingTo = nil } } label: { Image(systemName: "xmark.circle.fill") }
                }
                .font(.caption).padding(.horizontal).padding(.top, 8).foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                TextField(replyingTo == nil ? "Añade un comentario..." : "Escribe tu respuesta...", text: $newCommentText, axis: .vertical)
                    .textFieldStyle(.plain).padding(10).background(Color(.systemGray5)).clipShape(Capsule()).lineLimit(1...4)
                Button {
                    Task { await postComment() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill").font(.title).foregroundColor(newCommentText.isEmpty ? .gray : .blue)
                }.disabled(newCommentText.isEmpty)
            }
            .padding(.horizontal).padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    private func postComment() async {
        guard let author = currentUser, !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
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
