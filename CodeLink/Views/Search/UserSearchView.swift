//
//  UserSearchView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//

import SwiftUI

struct UserSearchView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authService: AuthService // <-- NUEVO: Recibe AuthService
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText: String = ""
    
    // Paleta de colores reutilizada de Theme.swift
    private let primaryDark = Color(red: 0.05, green: 0.08, blue: 0.15)
    private let secondaryDark = Color(red: 0.08, green: 0.12, blue: 0.20)
    private let accentBlue = Color(red: 0.20, green: 0.50, blue: 0.85)
    private let lightBlue = Color(red: 0.40, green: 0.70, blue: 0.95)
    private let softWhite = Color.white.opacity(0.95)
    private let glassMorphism = Color.white.opacity(0.08)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo similar al de otras vistas de la app
                LinearGradient(
                    colors: [primaryDark, secondaryDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    searchBar
                    
                    if viewModel.isLoading {
                        ProgressView("Buscando usuarios...")
                            .tint(lightBlue)
                            .foregroundColor(softWhite)
                            .padding()
                    } else if viewModel.users.isEmpty && !searchText.isEmpty {
                        emptyStateView(message: "No se encontraron usuarios para '\(searchText)'")
                    } else if searchText.isEmpty {
                        emptyStateView(message: "Empieza a escribir para buscar usuarios")
                    } else {
                        userResultsList
                    }
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Buscar Usuarios")
                        .font(.title2.bold())
                        .foregroundColor(softWhite)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(lightBlue)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(glassMorphism)
                                    .overlay(
                                        Circle()
                                            .stroke(lightBlue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
        }
    }
    
    private var searchBar: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(softWhite.opacity(0.7))
                
                TextField("Buscar por nombre de usuario o nombre completo", text: $searchText)
                    .foregroundColor(softWhite)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: searchText) { newValue in
                        viewModel.searchUsers(query: newValue)
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(softWhite.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(glassMorphism)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(accentBlue.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    private var userResultsList: some View {
        List {
            ForEach(viewModel.users) { user in
                NavigationLink(destination: ProfileView(authService: authService, user: user)) { // <-- CAMBIO AQUÍ: Pasa authService
                    HStack(spacing: 12) {
                        AvatarView(imageURL: user.profilePictureURL, size: 44)
                        VStack(alignment: .leading) {
                            Text(user.fullName)
                                .font(.headline)
                                .foregroundColor(softWhite)
                            Text("@\(user.username)")
                                .font(.subheadline)
                                .foregroundColor(lightBlue.opacity(0.8))
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
    }
    
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(accentBlue.opacity(0.6))
            Text(message)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(softWhite.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 50)
    }
}

struct UserSearchView_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchView(authService: AuthService()) // Pasa un AuthService de ejemplo para el Preview
    }
}
