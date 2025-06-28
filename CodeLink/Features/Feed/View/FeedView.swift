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
    
    // Paleta de colores elegante
    private let primaryDark = Color(red: 0.05, green: 0.08, blue: 0.15)
    private let secondaryDark = Color(red: 0.08, green: 0.12, blue: 0.20)
    private let accentBlue = Color(red: 0.20, green: 0.50, blue: 0.85)
    private let lightBlue = Color(red: 0.40, green: 0.70, blue: 0.95)
    private let softWhite = Color.white.opacity(0.95)
    private let glassMorphism = Color.white.opacity(0.08)
    
    var isAuthor: Bool {
        return publication.authorUid == currentUserId
    }
    
    var body: some View {
        let likesText = "\(publication.likes) Me gusta"
        let commentsText = "\(publication.commentCount) Comentar"
        
        VStack(alignment: .leading, spacing: 16) {
            // Cabecera con autor y menú de opciones
            HStack(spacing: 12) {
                // Avatar con diseño mejorado
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [lightBlue.opacity(0.3), accentBlue.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(softWhite)
                }
                .overlay(
                    Circle()
                        .stroke(lightBlue.opacity(0.3), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(publication.authorUsername)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(softWhite)
                    
                    Text(publication.formattedDate)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(lightBlue.opacity(0.7))
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
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(lightBlue)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(glassMorphism)
                                    .overlay(
                                        Circle()
                                            .stroke(lightBlue.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .menuStyle(.button)
                }
            }
            
            // Contenido de la publicación
            Text(publication.description)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(softWhite.opacity(0.9))
                .lineLimit(5)
                .lineSpacing(2)
            
            // Badge de estado
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(accentBlue)
                        .frame(width: 6, height: 6)
                    
                    Text(publication.status.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(lightBlue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(secondaryDark.opacity(0.6))
                        .overlay(
                            Capsule()
                                .stroke(lightBlue.opacity(0.3), lineWidth: 1)
                        )
                )
                
                Spacer()
            }
            
            // Línea divisoria elegante
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, lightBlue.opacity(0.3), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            // Botones de interacción
            HStack(spacing: 0) {
                Spacer()
                
                // Botón de Like
                Button {
                    youLiked.toggle()
                    publicationService.likePublication(publicationId: publication.id, currentLikes: publication.likes, shouldLike: youLiked)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: youLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.system(size: 16, weight: .medium))
                            .scaleEffect(youLiked ? 1.1 : 1.0)
                        
                        Text(likesText)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(youLiked ? lightBlue : softWhite.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(youLiked ? accentBlue.opacity(0.2) : glassMorphism)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        youLiked ? lightBlue.opacity(0.4) : lightBlue.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: youLiked)
                
                Spacer()
                
                // Botón de Comentarios
                Button {
                    showingComments = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(commentsText)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(softWhite.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(glassMorphism)
                            .overlay(
                                Capsule()
                                    .stroke(lightBlue.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(secondaryDark.opacity(0.6))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(glassMorphism)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [lightBlue.opacity(0.3), accentBlue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: primaryDark.opacity(0.4), radius: 10, x: 0, y: 4)
        )
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
    
    // Paleta de colores
    private let primaryDark = Color(red: 0.05, green: 0.08, blue: 0.15)
    private let pureBlack = Color(red: 0.02, green: 0.02, blue: 0.05)
    private let lightBlue = Color(red: 0.40, green: 0.70, blue: 0.95)
    private let accentBlue = Color(red: 0.20, green: 0.50, blue: 0.85)
    private let softWhite = Color.white.opacity(0.95)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo principal con gradiente
                LinearGradient(
                    colors: [pureBlack, primaryDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Header del feed con estadísticas
                        headerSection
                        
                        // Lista de publicaciones
                        ForEach($viewModel.publications) { $publication in
                            NavigationLink(destination: PublicationDetailView(publication: publication, currentUser: authService.appUser)) {
                                PublicationRowView(
                                    publication: $publication,
                                    currentUserId: authService.appUser?.id ?? "",
                                    currentUser: authService.appUser
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Espacio para el botón flotante
                }
                .refreshable {
                    // Funcionalidad de refresh se mantiene
                }
                
                // Botón flotante para crear publicación
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingCreateButton
                    }
                }
                .padding(.trailing, 24)
                .padding(.bottom, 34)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CodeLink")
                        .font(.title2.bold())
                        .foregroundColor(Color.white.opacity(0.95)) // softWhite
                }
            }

            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(primaryDark.opacity(0.95), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .sheet(isPresented: $showingCreatePublication) {
            if let currentUser = authService.appUser {
                CreatePublicationView(author: currentUser)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Últimas Publicaciones")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(softWhite)
                    
                    Text("Descubre contenido de la comunidad")
                        .font(.subheadline)
                        .foregroundColor(lightBlue.opacity(0.7))
                }
                
                Spacer()
                
                // Indicador de nuevas publicaciones
                if !viewModel.publications.isEmpty {
                    VStack(spacing: 2) {
                        Text("\(viewModel.publications.count)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(lightBlue)
                        
                        Text("posts")
                            .font(.caption2)
                            .foregroundColor(lightBlue.opacity(0.7))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accentBlue.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(lightBlue.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
            
            // Línea decorativa
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, lightBlue.opacity(0.4), accentBlue.opacity(0.3), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.horizontal, 40)
        }
        .padding(.top, 8)
    }
    
    private var floatingCreateButton: some View {
        Button {
            showingCreatePublication = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(softWhite)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [lightBlue, accentBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [softWhite.opacity(0.3), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: lightBlue.opacity(0.4), radius: 15, x: 0, y: 8)
                        .shadow(color: pureBlack.opacity(0.3), radius: 5, x: 0, y: 2)
                )
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingCreatePublication)
    }
}
