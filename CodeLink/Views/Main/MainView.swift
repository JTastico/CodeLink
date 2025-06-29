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
            // --- LA CORRECCIÓN CLAVE ESTÁ AQUÍ ---
            // Le pasamos el authService a FeedView para que esta pueda usarlo
            FeedView(authService: authService)
                .tabItem {
                    Label("Feed", systemImage: "house.fill")
                }

            // También se lo pasamos a ProfileView
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
