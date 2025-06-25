//
//  LoginView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct LoginView: View {
    // ANTES: @EnvironmentObject var authService: AuthService
    // AHORA: Es una variable normal que la vista está obligada a recibir.
    @ObservedObject var authService: AuthService
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("CodeLink")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Tu comunidad de desarrollo")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // Los botones ahora llamarán a la variable que recibimos
            Button {
                authService.signInWithGoogle()
            } label: {
                HStack {
                    Image(systemName: "g.circle.fill")
                    Text("Continuar con Google")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.bordered)
            
            Button {
                authService.signInWithGitHub()
            } label: {
                HStack {
                    Image(systemName: "g.circle.fill")
                    Text("Continuar con GitHub")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.bordered)
            .tint(.black)

            Spacer()
        }
        .padding()
    }
}

// Arreglamos la vista previa (preview) pasándole una instancia de AuthService
#Preview {
    LoginView(authService: AuthService())
}
