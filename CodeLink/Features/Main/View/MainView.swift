//
//  MainView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//


import SwiftUI

struct MainView: View {
    // Recibimos el servicio directamente
    @ObservedObject var authService: AuthService
    
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "house.fill")
                }

            // Se lo pasamos a ProfileView de la misma forma
            ProfileView(authService: authService)
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    MainView(authService: AuthService())
}
