//
//  LoginView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authService: AuthService
    
    var body: some View {
        ZStack {
            // Aplicamos el color de fondo a toda la pantalla
            Color.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Título con colores del tema
                VStack {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.accentColor)
                    
                    Text("CodeLink")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primaryTextColor)
                }
                .padding(.bottom, 20)

                Text("Tu comunidad de desarrollo")
                    .font(.headline)
                    .foregroundStyle(Color.secondaryTextColor)
                
                Spacer()
                
                // Botones con nuestro nuevo estilo personalizado
                Button {
                    authService.signInWithGoogle()
                } label: {
                    HStack {
                        // Podrías añadir un logo de Google aquí si quisieras
                        Text("Continuar con Google")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button {
                    authService.signInWithGitHub()
                } label: {
                    HStack {
                        // Podrías añadir un logo de GitHub aquí
                        Text("Continuar con GitHub")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .tint(.white) // Le damos un tinte para que el efecto visual sea más claro
                .foregroundColor(Color.backgroundColor) // Texto oscuro
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LoginView(authService: AuthService())
}
