//
//  PublicationDetailView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct PublicationDetailView: View {
    let publication: Publication
    let currentUser: User?
    
    @StateObject private var viewModel: CommentsViewModel

    @State private var newCommentText: String = ""
    private let publicationService = PublicationService()

    init(publication: Publication, currentUser: User?) {
        self.publication = publication
        self.currentUser = currentUser
        _viewModel = StateObject(wrappedValue: CommentsViewModel(publicationId: publication.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "person.circle.fill").font(.largeTitle).foregroundStyle(.gray)
                        VStack(alignment: .leading) {
                            Text(publication.authorUsername).font(.headline)
                            Text(publication.formattedDate).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    
                    Text(publication.description).font(.body)
                    
                    Divider()
                    
                    Text("Comentarios").font(.headline).padding(.bottom, 4)
                    
                    if viewModel.comments.isEmpty {
                        Text("Aún no hay comentarios. ¡Sé el primero!")
                            .font(.caption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center).padding(.vertical)
                    } else {
                        ForEach(viewModel.comments) { comment in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(comment.authorUsername).font(.caption.bold())
                                Text(comment.text).font(.callout)
                                Text(comment.formattedDate).font(.caption2).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(.bottom, 8)
                            Divider()
                        }
                    }
                }
                .padding()
            }
            
            if currentUser != nil {
                HStack(spacing: 12) {
                    TextField("Escribe un comentario...", text: $newCommentText)
                        .textFieldStyle(.plain).padding(10)
                        .background(Color(.systemGray6)).clipShape(Capsule())
                    
                    Button { Task { await postComment() } } label: {
                        Image(systemName: "paperplane.circle.fill").font(.title)
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(.thinMaterial)
            }
        }
        .navigationTitle(publication.status.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func postComment() async {
        guard let author = currentUser, !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let commentToPost = newCommentText
        newCommentText = ""
        
        do {
            try await publicationService.addComment(text: commentToPost, to: publication, by: author)
        } catch {
            print("Error al postear comentario: \(error)")
            newCommentText = commentToPost
        }
    }
}

#Preview {
    let sampleAuthor = User(id: "123", username: "preview_user", fullName: "Preview Name", email: "preview@test.com", profilePictureURL: nil, field: "iOS Developer", aboutMe: nil)
    let samplePublication = Publication(id: "abc", authorUid: "123", authorUsername: "preview_user", description: "Esta es una descripción de ejemplo.", imageURL: nil, createdAt: Date().timeIntervalSince1970, status: .help, likes: 0, commentCount: 0)
    
    NavigationStack {
        PublicationDetailView(publication: samplePublication, currentUser: sampleAuthor)
    }
}
