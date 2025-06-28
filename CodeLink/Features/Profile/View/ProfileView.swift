//
//  ProfileView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authService: AuthService
    @State private var showingEditProfile = false
    
    // Paleta de colores
    private let primaryDark = Color(red: 0.08, green: 0.10, blue: 0.18)
    private let glassMorphism = Color.white.opacity(0.08)
    private let accentBlue = Color(red: 0.20, green: 0.50, blue: 0.85)
    private let softWhite = Color.white.opacity(0.95)
    private let pureBlack = Color(red: 0.02, green: 0.02, blue: 0.05)

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [pureBlack, primaryDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if let user = authService.appUser {
                    ScrollView {
                        VStack(spacing: 28) {
                            profileHeader(user: user)
                                .transition(AnyTransition.move(edge: .top).combined(with: AnyTransition.opacity))
                                .animation(Animation.easeOut, value: showingEditProfile)

                            if let aboutMe = user.aboutMe, !aboutMe.isEmpty {
                                glassSection(title: "Acerca de mí") {
                                    Text(aboutMe)
                                        .font(.body)
                                        .foregroundColor(softWhite.opacity(0.9))
                                }
                            }

                            glassSection(title: "Configuración") {
                                Button("Editar Perfil") {
                                    showingEditProfile = true
                                }
                                .font(.headline)
                                .foregroundColor(accentBlue)
                            }

                            glassSection(title: "Cuenta") {
                                Button("Cerrar Sesión", role: .destructive) {
                                    authService.signOut()
                                }
                                .font(.headline)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                        .padding(.bottom, 80)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Perfil")
                        .font(.title2.bold())
                        .foregroundColor(Color.white.opacity(0.95)) // softWhite
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(user: authService.appUser!, authService: authService)
            }
        }
    }

    @ViewBuilder
    private func profileHeader(user: User) -> some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: user.profilePictureURL ?? "")) { image in
                image.resizable()
                     .aspectRatio(contentMode: .fill)
                     .frame(width: 110, height: 110)
                     .clipShape(Circle())
                     .overlay(Circle().stroke(accentBlue, lineWidth: 2))
                     .shadow(color: accentBlue.opacity(0.4), radius: 10, x: 0, y: 4)
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 110))
                    .foregroundStyle(.gray.opacity(0.3))
            }

            VStack(spacing: 4) {
                Text(user.fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(softWhite)

                Text("@\(user.username)")
                    .font(.callout)
                    .foregroundColor(softWhite.opacity(0.6))

                Text(user.field)
                    .font(.subheadline)
                    .foregroundColor(accentBlue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(glassMorphism)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(primaryDark.opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(accentBlue.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    private func glassSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(accentBlue)
            
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(glassMorphism)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(primaryDark.opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(softWhite.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ProfileView(authService: AuthService())
}
