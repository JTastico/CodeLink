//
//  FeedView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @ObservedObject var authService: AuthService
    @State private var showingCreatePublication = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 20) {
                        headerSection

                        ForEach($viewModel.publications) { $publication in
                            NavigationLink(destination:
                                PublicationDetailView(publication: publication, currentUser: authService.appUser)
                            ) {
                                PublicationRowView(publication: $publication,
                                                   currentUserId: authService.appUser?.id ?? "",
                                                   currentUser: authService.appUser)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingCreatePublication = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 34)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CodeLink").font(.title2.bold()).foregroundColor(.primary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingCreatePublication) {
            if let user = authService.appUser {
                CreatePublicationView(author: user)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Últimas Publicaciones").font(.title2.bold()).foregroundColor(.primary)
                    Text("Descubre contenido de la comunidad").font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
            }
            Rectangle()
                .fill(LinearGradient(colors: [.clear, .blue.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1.5)
                .padding(.horizontal, 40)
        }
        .padding(.top, 8)
    }
}
