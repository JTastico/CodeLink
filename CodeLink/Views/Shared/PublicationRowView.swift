//
//  PublicationRowView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//

import SwiftUI

struct PublicationRowView: View {
    @Binding var publication: Publication
    let currentUserId: String
    let currentUser: User?

    private let publicationService = PublicationService()
    @State private var showingEditView = false
    @State private var showingComments = false
    
    var isAuthor: Bool { publication.authorUid == currentUserId }

    var body: some View {
        let likesText = "\(publication.likes) Me gusta"
        let commentsText = "\(publication.commentCount) Comentar"

        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                AvatarView(imageURL: publication.authorProfilePictureURL, size: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(publication.authorUsername).font(.system(size: 16, weight: .semibold)).foregroundColor(.primary)
                    Text(publication.formattedDate).font(.system(size: 12)).foregroundColor(.secondary)
                }
                Spacer()
                if isAuthor {
                    Menu {
                        Button { showingEditView = true } label: { Label("Editar", systemImage: "pencil") }
                        Button(role: .destructive) {
                            Task { try? await publicationService.deletePublication(publication) }
                        } label: { Label("Eliminar", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis").padding(8).background(Color.blue.opacity(0.1)).clipShape(Circle())
                    }
                }
            }

            Text(publication.description)
                .font(.system(size: 15)).foregroundColor(.primary).lineLimit(5).lineSpacing(3)
            
            if let imageURLString = publication.imageURL, let imageURL = URL(string: imageURLString) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 250, alignment: .center)
                        .cornerRadius(15)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 250)
                        .cornerRadius(15)
                        .overlay(ProgressView())
                }
                .padding(.vertical, 8)
            }

            Text(publication.status.displayName)
                .font(.caption.bold()).padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.blue.opacity(0.2)).foregroundColor(.blue).clipShape(Capsule())

            Divider()

            HStack {
                Spacer()
                Button {
                    publicationService.likePublication(publicationId: publication.id, currentLikes: publication.likes, shouldLike: true)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.thumbsup").font(.system(size: 16))
                        Text(likesText).font(.system(size: 14))
                    }
                }.buttonStyle(BorderlessButtonStyle()).foregroundColor(.secondary)
                Spacer()
                Button {
                    showingComments = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "text.bubble").font(.system(size: 16))
                        Text(commentsText).font(.system(size: 14))
                    }
                }.buttonStyle(BorderlessButtonStyle()).foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .sheet(isPresented: $showingEditView) {
            EditPublicationView(publication: $publication)
        }
        .sheet(isPresented: $showingComments) {
            if let currentUser = currentUser {
                CommentsView(publication: publication, currentUser: currentUser)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}
