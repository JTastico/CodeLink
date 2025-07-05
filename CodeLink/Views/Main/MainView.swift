//
//  MainView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var authService: AuthService
    
    var body: some View {
        TabView {
            // Pestaña de Inicio (Feed)
            FeedView(authService: authService)
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }

            // --- PESTAÑA DE NOTIFICACIONES ---
            NotificationsView(authService: authService) // Pasa authService a NotificationsView
                .tabItem {
                    Label("Notificaciones", systemImage: "bell.fill")
                }
            
            // --- NUEVA PESTAÑA DE MENSAJES ---
            ConversationsListView(authService: authService)
                .tabItem {
                    Label("Mensajes", systemImage: "message.fill")
                }
            
            // Pestaña de Perfil
            ProfileView(authService: authService)
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
            
            // Pestaña de Configuración
            SettingsView(authService: authService)
                .tabItem {
                    Label("Configuración", systemImage: "gear")
                }
        }
        // Para que los colores de los iconos de la TabView se vean bien en modo oscuro
        .accentColor(.accentBlue) // Usando .accentBlue de Theme.swift
    }
}

#Preview {
    MainView(authService: AuthService())
}
