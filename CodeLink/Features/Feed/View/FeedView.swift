//
//  FeedView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

// --- SUB-VISTA PARA CADA FILA DE LA LISTA ---
// Extraemos la lógica de cada fila a su propia vista para ayudar al compilador.
struct PublicationRowView: View {
    // Usamos @Binding para que los cambios (como los likes) se actualicen en el ViewModel
    @Binding var publication: Publication
    let currentUserId: String
    let currentUser: User? // Necesitamos el objeto User completo para los comentarios
    
    private let publicationService = PublicationService()
    
    @State private var showingEditView = false
    @State private var showingComments = false
    @State private var youLiked = false
    
    // Comprueba si el usuario actual es el autor de la publicación
    var isAuthor: Bool {
        return publication.authorUid == currentUserId
    }
    
    // --- LA CORRECCIÓN CLAVE ---
    /// Creamos propiedades computadas para los textos de los botones.
    /// Esto simplifica la vista y evita que el compilador se confunda.
    private var likesLabel: String {
        "\(publication.likes) Me gusta"
    }
    
    private var commentLabel: String {
        "\(publication.commentCount) Comentar"
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
                
                // Menú de opciones (solo para el autor)
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
            
            // Contenido de la publicación
            Text(publication.description)
            
            HStack {
                Text(publication.status.displayName)
                    .font(.caption.bold()).padding(6)
                    .background(Color.blue.opacity(0.2)).clipShape(Capsule())
                Spacer()
            }
            
            Divider()
            
            // --- BOTONES DE INTERACCIÓN (USANDO LAS PROPIEDADES CORREGIDAS) ---
            HStack(spacing: 20) {
                Spacer()
                Button {
                    youLiked.toggle()
                    publicationService.likePublication(publicationId: publication.id, currentLikes: publication.likes, shouldLike: youLiked)
                } label: {
                    // Ahora usamos la propiedad computada, que es más simple.
                    Label(likesLabel, systemImage: youLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                }
                .tint(youLiked ? .blue : .secondary)
                
                Button {
                    showingComments = true
                } label: {
                    // Ahora usamos la propiedad computada, que es más simple.
                    Label(commentLabel, systemImage: "text.bubble")
                }
                Spacer()
            }
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingEditView) {
            // Hoja modal para editar
            EditPublicationView(publication: $publication)
        }
        // Hoja modal para los comentarios
        .sheet(isPresented: $showingComments) {
            // Se presenta solo si tenemos los datos del usuario actual
            if let currentUser = currentUser {
                CommentsView(publication: publication, currentUser: currentUser)
                    // Presenta la hoja con un tamaño mediano y un indicador para arrastrar
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
            List {
                ForEach($viewModel.publications) { $publication in
                    // Pasamos el usuario actual a la fila para que pueda usarlo la vista de comentarios
                    PublicationRowView(publication: $publication, currentUserId: authService.appUser?.id ?? "", currentUser: authService.appUser)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Feed")
            .toolbar {
                Button {
                    showingCreatePublication = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $showingCreatePublication) {
                if let currentUser = authService.appUser {
                    CreatePublicationView(author: currentUser)
                }
            }
        }
    }
}
