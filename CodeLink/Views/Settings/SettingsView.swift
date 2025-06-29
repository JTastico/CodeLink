//
//  SettingsView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authService: AuthService
    @State private var showingEditProfile = false
    
    // Estado para los toggles (opcional, para que funcionen)
    @State private var pushNotificationsOn = true
    @State private var emailNotificationsOn = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Reutilizamos el fondo degradado de la app
                Color.primaryGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        
                        // --- TUS SECCIONES PRESERVADAS ---
                        SettingsSection(title: "Notificaciones") {
                            Toggle("Notificaciones Push", isOn: $pushNotificationsOn)
                                .tint(Color.accentBlue)
                            Divider().background(Color.white.opacity(0.1))
                            Toggle("Notificaciones por Email", isOn: $emailNotificationsOn)
                                .tint(Color.accentBlue)
                        }
                        
                        SettingsSection(title: "Apariencia") {
                            HStack {
                                Text("Modo Oscuro")
                                Spacer()
                                Text("Siempre activo")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // --- SECCIÓN DE PERFIL (RENOMBRADA PARA CLARIDAD) ---
                        SettingsSection(title: "Mi Perfil") {
                            Button("Editar Perfil") {
                                showingEditProfile = true
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        
                        // --- SECCIÓN DE CUENTA CON DISEÑO PERSONALIZADO ---
                        SettingsSection(title: "Cuenta") {
                            VStack(alignment: .leading, spacing: 12) { // Alineamos los botones a la izquierda
                                
                                // Botón para Cerrar Sesión con estilo personalizado
                                Button("Cerrar Sesión") {
                                    authService.signOut()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading) // Ocupa todo el ancho y alinea el texto a la izquierda
                                .foregroundColor(.red)
                                .padding()
                                .cornerRadius(0) // Bordes rectos
                                
                                // Botón para Eliminar Cuenta con estilo personalizado
                                Button("Eliminar mi cuenta", role: .destructive) {
                                    // Aquí iría la lógica para eliminar la cuenta
                                }
                                .frame(maxWidth: .infinity, alignment: .leading) // Ocupa todo el ancho y alinea el texto a la izquierda
                                .foregroundColor(.red)
                                .padding()
                                .cornerRadius(0) // Bordes rectos
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.deepBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showingEditProfile) {
                if let user = authService.appUser {
                    let profileController = ProfileController(user: user, authService: authService)
                    EditProfileView(controller: profileController)
                }
            }
        }
    }
}

// Un componente reutilizable para las secciones
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.accentBlue)
                .padding(.leading)
            
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard() // Reutilizamos el estilo de tarjeta de la app
        }
    }
}

#Preview {
    SettingsView(authService: AuthService())
        .preferredColorScheme(.dark)
}
