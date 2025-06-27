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
        // Creamos constantes locales para simplificar la vista y evitar errores del compilador.
        let likesText = "\(publication.likes) Me gusta"
        let commentsText = "\(publication.commentCount) Comentar"
        
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
            
            // Botones de interacción
            HStack(spacing: 20) {
                Spacer()
                // --- BOTÓN "ME GUSTA" CON ANIMACIÓN ---
                Button {
                    // La lógica del like no cambia
                    youLiked.toggle()
                    publicationService.likePublication(publicationId: publication.id, currentLikes: publication.likes, shouldLike: youLiked)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: youLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            // --- 1. Animación de Escala ---
                            // El ícono crece un 20% cuando 'youLiked' es verdadero.
                            .scaleEffect(youLiked ? 1.2 : 1.0)
                        Text(likesText)
                    }
                }
                .tint(youLiked ? .blue : .secondary)
                // --- 2. Modificador de Animación ---
                // Le decimos a SwiftUI que anime cualquier cambio que dependa de 'youLiked'
                // usando una animación de resorte (spring) para un efecto de "rebote".
                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: youLiked)
                
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
