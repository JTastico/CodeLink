//
//  ProfileView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authService: AuthService
    @StateObject private var feedViewModel = FeedViewModel()
    @State private var isAnimating = false

    // --- CAMBIO AQUÍ: La vista ahora acepta un 'User' opcional ---
    // Si se inicializa con un usuario, se muestra ese perfil.
    // Si no se proporciona (o es nil), asume que es el perfil del usuario autenticado.
    var userToShow: User?
    
    // Propiedad computada para obtener el usuario que se debe mostrar
    private var displayUser: User? {
        userToShow ?? authService.appUser
    }

    // Filtra las publicaciones para mostrar solo las del usuario actual o el usuario pasado
    private var myPublications: [Binding<Publication>] {
        feedViewModel.publications
            .filter { $0.authorUid == displayUser?.id } // Filtra por el ID del usuario a mostrar
            .map { publication in
                // Encuentra el índice de la publicación en el array original para poder enlazarlo (Binding)
                let index = feedViewModel.publications.firstIndex(where: { $0.id == publication.id })!
                return $feedViewModel.publications[index]
            }
    }
    
    // --- NUEVO INICIALIZADOR ---
    // Esto permite que ProfileView sea reutilizable.
    // Si `user` es nil, mostrará el perfil del usuario autenticado (se usará en MainView).
    // Si se pasa un `user`, mostrará ese perfil (se usará desde UserSearchView).
    init(authService: AuthService, user: User? = nil) {
        self.authService = authService
        self.userToShow = user
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryGradient
                    .ignoresSafeArea()
                    .opacity(isAnimating ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 1.5), value: isAnimating)

                if let user = displayUser { // Usa displayUser aquí
                    ScrollView {
                        VStack(spacing: 28) {
                            profileHeader(user: user)
                                .transition(AnyTransition.move(edge: .top).combined(with: AnyTransition.opacity))

                            if let aboutMe = user.aboutMe, !aboutMe.isEmpty {
                                glassSection(title: "Acerca de mí") {
                                    Text(aboutMe)
                                        .font(.body)
                                        .foregroundColor(Color.primaryTextColor)
                                }
                            }

                            // --- SECCIÓN DE PUBLICACIONES ---
                            myPublicationsSection
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                        .padding(.bottom, 80)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Perfil")
                        .font(.title2.bold())
                        .foregroundColor(Color.primaryTextColor)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setupAnimations()
            }
        }
    }

    @ViewBuilder
    private var myPublicationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Publicaciones") // Cambiado a "Publicaciones" genérico
                .font(.headline)
                .foregroundColor(Color.accentBlue)
                .padding(.horizontal)

            if myPublications.isEmpty {
                VStack {
                    Text("Aún no se han realizado publicaciones.") // Mensaje más genérico
                        .foregroundColor(.secondaryTextColor)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .glassCard(cornerRadius: 20)
                
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(myPublications, id: \.id) { $publication in
                        PublicationRowView(publication: $publication,
                                           currentUserId: authService.appUser?.id ?? "",
                                           currentUser: authService.appUser)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func profileHeader(user: User) -> some View {
        VStack(spacing: 16) {
            AvatarView(imageURL: user.profilePictureURL, size: 110, showBorder: true)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)

            VStack(spacing: 4) {
                Text(user.fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryTextColor)

                Text("@\(user.username)")
                    .font(.callout)
                    .foregroundColor(Color.secondaryTextColor)

                Text(user.field)
                    .font(.subheadline)
                    .foregroundColor(Color.accentBlue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassCard(cornerRadius: 24)
        .scaleEffect(isAnimating ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func glassSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.accentBlue)
            
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 20)
        .scaleEffect(isAnimating ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
    }
    
    private func setupAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isAnimating = true
            }
        }
    }
}
