//
//  ProfileView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct ProfileView: View {
    // Recibe el servicio de autenticación para acceder a los datos del usuario.
    @ObservedObject var authService: AuthService
    
    // Un estado para controlar si se muestra o no la hoja modal de edición.
    @State private var showingEditProfile = false

    var body: some View {
        NavigationStack {
            // Usamos un 'if let' para mostrar los datos solo cuando se hayan cargado desde Firebase.
            if let user = authService.appUser {
                Form {
                    Section("Mi Perfil") {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                // Muestra la foto de perfil del usuario desde una URL.
                                AsyncImage(url: URL(string: user.profilePictureURL ?? "")) { image in
                                    image.resizable()
                                         .aspectRatio(contentMode: .fill)
                                         .frame(width: 100, height: 100)
                                         .clipShape(Circle())
                                } placeholder: {
                                    // Muestra un ícono de placeholder mientras carga la imagen o si no hay URL.
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 100))
                                        .foregroundStyle(.gray)
                                }
                                
                                Text(user.fullName)
                                    .font(.title)
                                    .fontWeight(.bold)
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
                    
                    // NUEVA SECCIÓN: Muestra la biografía solo si no está vacía.
                    if let aboutMe = user.aboutMe, !aboutMe.isEmpty {
                        Section("Acerca de mí") {
                            Text(aboutMe)
                        }
                    }
                    
                    Section {
                        Button("Cerrar Sesión", role: .destructive) {
                            authService.signOut()
                        }
                    }
                }
                .navigationTitle("Perfil")
                .toolbar {
                    // Botón en la barra de navegación para abrir la vista de edición.
                    Button("Editar") {
                        showingEditProfile = true
                    }
                }
                .sheet(isPresented: $showingEditProfile) {
                    // Presenta la vista EditProfileView como una hoja modal.
                    // Le pasamos el usuario actual y el servicio de autenticación.
                    EditProfileView(user: user, authService: authService)
                }
            } else {
                // Muestra un indicador de carga mientras se obtienen los datos del perfil.
                ProgressView()
                    .navigationTitle("Perfil")
            }
        }
    }
}

// Vista previa para el lienzo de Xcode.
#Preview {
    // Creamos una instancia de AuthService para que la vista previa funcione.
    ProfileView(authService: AuthService())
}
