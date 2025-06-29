//
//  LoginView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authService: AuthService
    @State private var isAnimating = false
    @State private var showError = false
    
    // Colores del diseño general
    private let primaryDark = Color(red: 0.05, green: 0.08, blue: 0.15)
    private let secondaryDark = Color(red: 0.08, green: 0.12, blue: 0.20)
    private let accentBlue = Color(red: 0.20, green: 0.50, blue: 0.85)
    private let lightBlue = Color(red: 0.40, green: 0.70, blue: 0.95)
    private let softWhite = Color.white.opacity(0.95)
    private let glassMorphism = Color.white.opacity(0.08)
    
    var body: some View {
        ZStack {
            // Fondo degradado animado
            LinearGradient(
                colors: [primaryDark, secondaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                GeometryReader { geometry in
                    Circle()
                        .fill(lightBlue.opacity(0.1))
                        .frame(width: geometry.size.width * 0.8)
                        .position(
                            x: geometry.size.width * 0.8,
                            y: geometry.size.height * 0.2
                        )
                        .blur(radius: 60)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                }
            )
            .overlay(
                GeometryReader { geometry in
                    Circle()
                        .fill(accentBlue.opacity(0.1))
                        .frame(width: geometry.size.width * 0.6)
                        .position(
                            x: geometry.size.width * 0.2,
                            y: geometry.size.height * 0.8
                        )
                        .blur(radius: 60)
                        .scaleEffect(isAnimating ? 0.8 : 1.2)
                }
            )

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(lightBlue)
                        .shadow(color: lightBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(Animation.linear(duration: 20).repeatForever(autoreverses: false), value: isAnimating)

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
                        withAnimation(.spring()) {
                            authService.signInWithGoogle()
                        }
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
                        withAnimation(.spring()) {
                            authService.signInWithGitHub()
                        }
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
            .opacity(authService.isLoading ? 0.6 : 1)
            .blur(radius: authService.isLoading ? 3 : 0)
            .overlay {
                if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: lightBlue))
                        .scaleEffect(1.5)
                }
            }
        }
        .alert("Error de Autenticación", isPresented: Binding(
            get: { authService.authError != nil },
            set: { if !$0 { authService.authError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = authService.authError {
                Text(error)
            }
        }
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LoginView(authService: AuthService())
}
