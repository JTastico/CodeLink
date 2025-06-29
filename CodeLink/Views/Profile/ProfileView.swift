//
//  ProfileView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authService: AuthService
    @State private var isAnimating = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryGradient
                    .ignoresSafeArea()
                    .opacity(isAnimating ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 1.5), value: isAnimating)

                if let user = authService.appUser {
                    ScrollView {
                        VStack(spacing: 28) {
                            profileHeader(user: user)
                                .transition(AnyTransition.move(edge: .top).combined(with: AnyTransition.opacity))

                            if let aboutMe = user.aboutMe, !aboutMe.isEmpty {
                                glassSection(title: "Acerca de mí") {
                                    Text(aboutMe)
                                        .font(.body)
                                        .foregroundColor(Color.primaryTextColor)
                                }
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
                        .foregroundColor(Color.primaryTextColor)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setupAnimations()
            }
        }
    }

    @ViewBuilder
    private func profileHeader(user: User) -> some View {
        VStack(spacing: 16) {
            AvatarView(imageURL: user.profilePictureURL, size: 110, showBorder: true)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)

            VStack(spacing: 4) {
                Text(user.fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryTextColor)

                Text("@\(user.username)")
                    .font(.callout)
                    .foregroundColor(Color.secondaryTextColor)

                Text(user.field)
                    .font(.subheadline)
                    .foregroundColor(Color.accentBlue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassCard(cornerRadius: 24)
        .scaleEffect(isAnimating ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func glassSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.accentBlue)
            
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 20)
        .scaleEffect(isAnimating ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
    }
    
    private func setupAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isAnimating = true
            }
        }
    }
}
