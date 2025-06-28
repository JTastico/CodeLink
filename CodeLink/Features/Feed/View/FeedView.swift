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
    @State private var isAnimating = false

    var isAuthor: Bool { publication.authorUid == currentUserId }

    var body: some View {
        let likesText = "\(publication.likes) Me gusta"
        let commentsText = "\(publication.commentCount) Comentar"

        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                // Icono de avatar por defecto
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundColor(.blue)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)

                VStack(alignment: .leading, spacing: 2) {
                    Text(publication.authorUsername)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(publication.formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isAuthor {
                    Menu {
                        Button { showingEditView = true } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            Task { try? await publicationService.deletePublication(publication) }
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .clipShape(Circle())
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                    }
                }
            }

            Text(publication.description)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineLimit(5)
                .lineSpacing(3)
                .opacity(isAnimating ? 1.0 : 0.9)
                .animation(.easeInOut(duration: 1.0), value: isAnimating)

            Text(publication.status.displayName)
                .font(.caption.bold())
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .clipShape(Capsule())

            Rectangle()
                .fill(LinearGradient(colors: [.clear, .blue.opacity(0.3), .clear],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
                .opacity(isAnimating ? 0.8 : 0.5)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)

            HStack {
                Spacer()
                Button {
                    youLiked.toggle()
                    publicationService.likePublication(publicationId: publication.id,
                                                       currentLikes: publication.likes,
                                                       shouldLike: youLiked)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: youLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.system(size: 16))
                            .scaleEffect(youLiked ? 1.1 : 1.0)
                        Text(likesText)
                            .font(.system(size: 14))
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .foregroundColor(youLiked ? .blue : .secondary)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: youLiked)

                Spacer()

                Button {
                    showingComments = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 16))
                        Text(commentsText)
                            .font(.system(size: 14))
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .foregroundColor(.secondary)

                Spacer()
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
        .scaleEffect(isAnimating ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear { withAnimation { isAnimating = true } }
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
    @State private var feedAnimating = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                    .opacity(feedAnimating ? 1 : 0.8)
                    .animation(.easeInOut(duration: 1.5), value: feedAnimating)

                ScrollView {
                    LazyVStack(spacing: 20) {
                        headerSection

                        ForEach(viewModel.publications.indices, id: \.self) { idx in
                            NavigationLink(destination:
                                PublicationDetailView(publication: viewModel.publications[idx],
                                                      currentUser: authService.appUser)
                            ) {
                                PublicationRowView(publication: $viewModel.publications[idx],
                                                   currentUserId: authService.appUser?.id ?? "",
                                                   currentUser: authService.appUser)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }

                VStack {
                    Spacer()
                    floatingCreateButton
                }
                .padding(.trailing, 24)
                .padding(.bottom, 34)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CodeLink")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                }
            }
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear { withAnimation { feedAnimating = true } }
        .sheet(isPresented: $showingCreatePublication) {
            if let user = authService.appUser {
                CreatePublicationView(author: user)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Últimas Publicaciones")
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                    Text("Descubre contenido de la comunidad")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if !viewModel.publications.isEmpty {
                    Text("\(viewModel.publications.count) posts")
                        .font(.headline.bold())
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                        .scaleEffect(feedAnimating ? 1.05 : 1)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: feedAnimating)
                }
            }
            Rectangle()
                .fill(LinearGradient(colors: [.clear, .blue.opacity(0.5), .clear],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(height: 2)
                .padding(.horizontal, 40)
                .opacity(feedAnimating ? 0.8 : 0.4)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: feedAnimating)
        }
        .padding(.top, 8)
    }

    private var floatingCreateButton: some View {
        Button {
            showingCreatePublication = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .buttonStyle(.borderedProminent)
        .scaleEffect(feedAnimating ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: feedAnimating)
    }
}
