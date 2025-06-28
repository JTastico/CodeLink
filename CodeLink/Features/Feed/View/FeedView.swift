//
//  FeedView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

// --- SUB-VISTA PARA CADA FILA DE LA LISTA ---
struct PublicationRowView: View {
    @Binding var publication: Publication
    let currentUserId: String
    let currentUser: User?
    
    private let publicationService = PublicationService()
    
    @State private var showingEditView = false
    @State private var showingComments = false
    @State private var youLiked = false
    
    var isAuthor: Bool {
        return publication.authorUid == currentUserId
    }
    
    var body: some View {
        let likesText = "\(publication.likes) Me gusta"
        let commentsText = "\(publication.commentCount) Comentar"
        
        VStack(alignment: .leading, spacing: 12) {
            // Cabecera con autor y menú de opciones
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
                VStack(alignment: .leading) {
                    Text(publication.authorUsername).font(.headline)
                    Text(publication.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                if isAuthor {
                    Menu {
                        Button { showingEditView = true } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            Task {
                                try? await publicationService.deletePublication(publication)
                            }
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .menuStyle(.button)
                }
            }
            
            Text(publication.description)
                .foregroundStyle(Color.primaryTextColor.opacity(0.9))
                .lineLimit(5)
            
            HStack {
                Text(publication.status.displayName)
                    .font(.caption.bold())
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
                Spacer()
            }
            
            Divider().background(Color.surfaceColor)
            
            HStack(spacing: 20) {
                Spacer()
                
                Button {
                    youLiked.toggle()
                    publicationService.likePublication(publicationId: publication.id, currentLikes: publication.likes, shouldLike: youLiked)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: youLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .scaleEffect(youLiked ? 1.2 : 1.0)
                        Text(likesText)
                    }
                }
                .tint(youLiked ? .blue : .secondary)
                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: youLiked)
                
                Button {
                    showingComments = true
                } label: {
                    Label(commentsText, systemImage: "text.bubble")
                }
                Spacer()
            }
            .foregroundStyle(Color.secondaryTextColor)
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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


// --- VISTA PRINCIPAL DEL FEED ---
struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @ObservedObject var authService: AuthService
    
    @State private var showingCreatePublication = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach($viewModel.publications) { $publication in
                        NavigationLink(destination: PublicationDetailView(publication: publication, currentUser: authService.appUser)) {
                            PublicationRowView(publication: $publication, currentUserId: authService.appUser?.id ?? "", currentUser: authService.appUser)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color.backgroundColor)
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button {
                    showingCreatePublication = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .sheet(isPresented: $showingCreatePublication) {
                if let currentUser = authService.appUser {
                    CreatePublicationView(author: currentUser)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
