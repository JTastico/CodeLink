//
//  ProfileView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct ProfileView: View {
    let user = User.example
    
    // Recibimos el servicio directamente
    @ObservedObject var authService: AuthService

    var body: some View {
        NavigationStack {
            Form {
                Section("Mi Perfil") {
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: user.profilePicture)
                                .font(.system(size: 80))
                            Text(user.fullName)
                                .font(.title)
                            Text("@\(user.username)")
                                .foregroundStyle(.secondary)
                            Text(user.field)
                                .font(.headline)
                                .padding(.top, 4)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section {
                    Button("Cerrar Sesión", role: .destructive) {
                        authService.signOut()
                    }
                }
            }
            .navigationTitle("Perfil")
        }
    }
}

// Asegurémonos de que el Preview esté correcto
#Preview {
    ProfileView(authService: AuthService())
}
