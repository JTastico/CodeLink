//
//  LoginView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authService: AuthService
    
    // Colores del diseño general
    private let primaryDark = Color(red: 0.05, green: 0.08, blue: 0.15)
    private let secondaryDark = Color(red: 0.08, green: 0.12, blue: 0.20)
    private let accentBlue = Color(red: 0.20, green: 0.50, blue: 0.85)
    private let lightBlue = Color(red: 0.40, green: 0.70, blue: 0.95)
    private let softWhite = Color.white.opacity(0.95)
    private let glassMorphism = Color.white.opacity(0.08)
    
    var body: some View {
        ZStack {
            // Fondo degradado
            LinearGradient(
                colors: [primaryDark, secondaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(lightBlue)
                        .shadow(color: lightBlue.opacity(0.4), radius: 8, x: 0, y: 4)

                    Text("CodeLink")
                        .font(.largeTitle.bold())
                        .foregroundStyle(softWhite)
                    
                    Text("Tu comunidad de desarrollo")
                        .font(.headline)
                        .foregroundStyle(lightBlue.opacity(0.7))
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.bottom, 20)

                VStack(spacing: 20) {
                    Button(action: {
                        authService.signInWithGoogle()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                            Text("Continuar con Google")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(lightBlue.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(lightBlue, lineWidth: 1)
                                )
                        )
                    }
                    .foregroundColor(softWhite)
                    .shadow(color: lightBlue.opacity(0.2), radius: 5, x: 0, y: 4)

                    Button(action: {
                        authService.signInWithGitHub()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "chevron.left.slash.chevron.right")
                            Text("Continuar con GitHub")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(glassMorphism)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(softWhite.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .foregroundColor(softWhite)
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.5), value: UUID()) // Fuerza animación suave
        }
    }
}

#Preview {
    LoginView(authService: AuthService())
}
