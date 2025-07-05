//
//  FeedView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @ObservedObject var authService: AuthService
    @State private var showingCreatePublication = false
    
    // 1. Estado para almacenar el filtro seleccionado
    @State private var selectedStatus: PublicationStatus? = nil
    
    // Estado para mostrar la búsqueda de usuarios (EXISTENTE, AHORA FUSIONADO)
    @State private var showingUserSearch = false

    var body: some View {
        NavigationStack {
            ZStack {
                // He cambiado el color a uno de los de tu tema para consistencia
                Color.backgroundColor.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 20) {
                        headerSection
                        
                        // 2. Barra de filtros añadida aquí
                        filterBar
                        
                        // 3. El ForEach ahora filtra las publicaciones
                        ForEach(viewModel.publications.filter { selectedStatus == nil || $0.status == selectedStatus }) { publication in
                            // Para mantener el Binding, buscamos el índice en la fuente original
                            if let index = viewModel.publications.firstIndex(where: { $0.id == publication.id }) {
                                NavigationLink(destination:
                                    PublicationDetailView(publication: publication, currentUser: authService.appUser)
                                ) {
                                    PublicationRowView(publication: $viewModel.publications[index],
                                                       currentUserId: authService.appUser?.id ?? "",
                                                       currentUser: authService.appUser)
                                        // Padding aplicado a la fila, como lo tenías
                                        .padding(.horizontal, 20)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.top)
                    .padding(.bottom, 100)
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingCreatePublication = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .buttonStyle(FloatingButtonStyle()) // Reutilizando tu estilo de botón flotante
                        .padding(.trailing, 24)
                        .padding(.bottom, 34)
                    }
                }
            }
            // CORRECCIÓN: Usar ToolbarItemGroup para evitar ambigüedad
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    Text("CodeLink").font(.title2.bold()).foregroundColor(.primaryTextColor)
                }
                // Botón de búsqueda de usuarios (RE-AÑADIDO)
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingUserSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primaryTextColor) // Usa el color de texto primario de tu tema
                    }
                }
            }
            .toolbarBackground(Color.backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingCreatePublication) {
            if let user = authService.appUser {
                CreatePublicationView(author: user)
            }
        }
        // Sheet para la vista de búsqueda de usuarios (RE-AÑADIDO)
        .sheet(isPresented: $showingUserSearch) {
            UserSearchView(authService: authService, onUserSelected: { _ in }) // Pasa authService
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Últimas Publicaciones").font(.title2.bold()).foregroundColor(.primaryTextColor)
                    Text("Descubre contenido de la comunidad").font(.subheadline).foregroundColor(.secondaryTextColor)
                }
                Spacer()
            }
            Rectangle()
                .fill(LinearGradient(colors: [.clear, Color.accentBlue.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1.5)
                .padding(.horizontal, 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // --- VISTA PARA LA BARRA DE FILTROS --- (EXISTENTE, AHORA INCLUIDA)
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Botón para mostrar todos
                FilterButton(
                    title: "Todos",
                    isSelected: selectedStatus == nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedStatus = nil
                    }
                }
                
                // Botones para cada tipo de publicación
                ForEach(PublicationStatus.allCases, id: \.self) { status in
                    FilterButton(
                        title: status.displayName,
                        isSelected: selectedStatus == status
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedStatus = status
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
}

// --- COMPONENTE REUTILIZABLE PARA LOS BOTONES DE FILTRO --- (EXISTENTE, AHORA INCLUIDO)
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        // Usamos tus colores y estilos para consistencia
                        if isSelected {
                            Capsule().fill(Color.accentBlue)
                                .shadow(color: Color.accentBlue.opacity(0.4), radius: 5, y: 2)
                        } else {
                            Capsule().fill(Color.surfaceColor)
                                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        }
                    }
                )
                .foregroundColor(isSelected ? .white : .secondaryTextColor)
        }
    }
}
