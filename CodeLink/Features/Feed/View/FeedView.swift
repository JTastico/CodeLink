//
//  FeedView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

// --- NUEVA SUB-VISTA DEDICADA PARA LAS ACCIONES ---
// Esta vista aísla la lógica de los botones, solucionando el bug del compilador.
struct PublicationActionsView: View {
    @Binding var publication: Publication
    @Binding var showingComments: Bool
    
    // Estado local para el botón de like
    @State private var youLiked = false
    private let publicationService = PublicationService()

    var body: some View {
        // Creamos constantes locales para simplificar al máximo.
        let likesText = "\(publication.likes) Me gusta"
        let commentsText = "\(publication.commentCount) Comentar"
        
        HStack(spacing: 20) {
            Spacer()
            Button {
                youLiked.toggle()
                publicationService.likePublication(publicationId: publication.id, currentLikes: publication.likes, shouldLike: youLiked)
            } label: {
                Label(likesText, systemImage: youLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
            }
            .tint(youLiked ? .blue : .secondary)
            
            Button {
                showingComments = true
            } label: {
                Label(commentsText, systemImage: "text.bubble")
            }
            Spacer()
        }
        .foregroundStyle(.secondary)
        .buttonStyle(.plain)
    }
}


// --- SUB-VISTA PARA CADA FILA (AHORA MÁS SIMPLE) ---
struct PublicationRowView: View {
    @Binding var publication: Publication
    let currentUserId: String
    let currentUser: User?
    
    private let publicationService = PublicationService()
    
    @State private var showingEditView = false
    @State private var showingComments = false
    
    var isAuthor: Bool {
        return publication.authorUid == currentUserId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cabecera con autor y menú de opciones
            HStack {
                Image(systemName: "person.circle.fill").font(.largeTitle).foregroundStyle(.gray)
                VStack(alignment: .leading) {
                    Text(publication.authorUsername).font(.headline)
                    Text(publication.formattedDate).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                
                if isAuthor {
                    Menu {
                        Button { showingEditView = true } label: { Label("Editar", systemImage: "pencil") }
                        Button(role: .destructive) {
                            Task { try? await publicationService.deletePublication(publication) }
                        } label: { Label("Eliminar", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis").padding(8).background(Color.gray.opacity(0.1)).clipShape(Circle())
                    }
                    .menuStyle(.button)
                }
            }
            
            Text(publication.description).lineLimit(5)
            
            HStack {
                Text(publication.status.displayName)
                    .font(.caption.bold()).padding(6)
                    .background(Color.blue.opacity(0.2)).clipShape(Capsule())
                Spacer()
            }
            
            Divider()
            
            // Ahora llamamos a nuestra nueva vista de acciones, mucho más simple.
            PublicationActionsView(publication: $publication, showingComments: $showingComments)
        }
        .padding(.vertical, 8)
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


// --- VISTA PRINCIPAL DEL FEED (SIN CAMBIOS) ---
struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @ObservedObject var authService: AuthService
    
    @State private var showingCreatePublication = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($viewModel.publications) { $publication in
                    NavigationLink(destination: PublicationDetailView(publication: publication, currentUser: authService.appUser)) {
                        PublicationRowView(publication: $publication, currentUserId: authService.appUser?.id ?? "", currentUser: authService.appUser)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Feed")
            .toolbar {
                Button { showingCreatePublication = true } label: { Image(systemName: "plus.circle.fill") }
            }
            .sheet(isPresented: $showingCreatePublication) {
                if let currentUser = authService.appUser {
                    CreatePublicationView(author: currentUser)
                }
            }
        }
    }
}
