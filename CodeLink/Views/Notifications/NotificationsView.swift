//
//  NotificationsView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject var authService: AuthService
    @StateObject private var viewModel: NotificationsViewModel
    
    // Estado para la navegación a la vista de detalle de publicación
    @State private var selectedPublication: Publication? = nil
    @State private var showingPublicationDetail = false
    
    // Instancia del servicio para obtener la publicación completa
    private let publicationService = PublicationService()

    init(authService: AuthService) {
        self.authService = authService
        // Inicializa el ViewModel con el ID del usuario actual
        _viewModel = StateObject(wrappedValue: NotificationsViewModel(currentUserId: authService.appUser?.id ?? ""))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Usa un color de fondo definido en Theme.swift
                Color.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection

                    if viewModel.isLoading {
                        ProgressView("Cargando notificaciones...")
                            .tint(.primaryTextColor)
                            .foregroundColor(.primaryTextColor)
                            .padding()
                    } else if viewModel.notifications.isEmpty {
                        emptyStateView
                    } else {
                        notificationsList
                    }
                }
            }
            .navigationTitle("Notificaciones")
            .navigationBarTitleDisplayMode(.inline)
            // Estilo de la barra de navegación
            .toolbarBackground(Color.backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            // Destino de navegación para la vista de detalle de publicación
            .navigationDestination(isPresented: $showingPublicationDetail) {
                if let publication = selectedPublication, let currentUser = authService.appUser {
                    PublicationDetailView(publication: publication, currentUser: currentUser)
                } else {
                    Text("Error al cargar publicación.").foregroundColor(.primaryTextColor) // Vista de fallback
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tus Notificaciones")
                    .font(.title2.bold())
                    .foregroundColor(.primaryTextColor)
                Spacer()
                // Aquí podrías añadir un botón para "Marcar todas como leídas"
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.backgroundColor) // Usa un color de fondo definido en Theme.swift
            Divider().background(Color.primaryTextColor.opacity(0.2))
        }
    }

    private var notificationsList: some View {
        List {
            ForEach(viewModel.notifications) { notification in
                Button(action: {
                    // 1. Marca la notificación como leída
                    viewModel.markNotificationAsRead(notification: notification)
                    
                    // 2. Si la notificación tiene un ID de publicación, intenta navegar
                    if let pubId = notification.publicationId {
                        Task {
                            do {
                                // Obtén la publicación completa usando el servicio
                                if let fetchedPublication = try await publicationService.getPublicationById(pubId) {
                                    self.selectedPublication = fetchedPublication // Almacena la publicación
                                    self.showingPublicationDetail = true // Activa la navegación
                                }
                            } catch {
                                print("Error al obtener publicación para la notificación: \(error)")
                            }
                        }
                    }
                }) {
                    NotificationRowView(notification: notification)
                }
                // Estilo de la fila de notificación (cambia color si está leída)
                .listRowBackground(notification.isRead ? Color.surfaceColor.opacity(0.5) : Color.cardBackground)
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
            }
            .onDelete(perform: deleteNotification) // Permite deslizar para eliminar
        }
        .listStyle(PlainListStyle()) // Estilo de lista sin fondo por defecto
        .scrollContentBackground(.hidden) // Oculta el fondo del scroll
        .refreshable {
            viewModel.startListeningForNotifications() // Permite recargar deslizando hacia abajo
        }
    }
    
    // Función para eliminar notificaciones
    private func deleteNotification(at offsets: IndexSet) {
        for index in offsets {
            let notification = viewModel.notifications[index]
            viewModel.deleteNotification(notification: notification)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentBlue.opacity(0.6))
            Text("No tienes notificaciones")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primaryTextColor.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 50)
    }
}

// Vista de fila para una única notificación
struct NotificationRowView: View {
    let notification: Notification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icono de campana (cambia de color si está leída)
            Image(systemName: "bell.badge.fill")
                .font(.title2)
                .foregroundColor(notification.isRead ? .secondaryTextColor : .accentBlue)
                .frame(width: 40, height: 40)
                .background(Circle().fill(notification.isRead ? Color.surfaceColor : Color.vibrantBlue.opacity(0.2)))
                .clipShape(Circle())


            VStack(alignment: .leading, spacing: 4) {
                // Mensaje principal de la notificación
                Text(notification.senderUsername)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(notification.isRead ? .secondaryTextColor : .primaryTextColor) +
                Text(" ha comentado tu publicación.")
                    .font(.system(size: 15))
                    .foregroundColor(notification.isRead ? .secondaryTextColor : .primaryTextColor)

                // Muestra el texto del comentario si existe
                if let commentText = notification.commentText, !commentText.isEmpty {
                    Text(commentText)
                        .font(.system(size: 14))
                        .foregroundColor(notification.isRead ? .tertiaryTextColor : .secondaryTextColor)
                        .lineLimit(2) // Limita a dos líneas
                }

                // Muestra la fecha de la notificación en formato relativo
                Text(Date(timeIntervalSince1970: notification.createdAt), format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundColor(.tertiaryTextColor)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Hace que toda la fila sea interactuable al tocar
    }
}
