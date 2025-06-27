//
//  FeedView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//


import SwiftUI

// --- NUEVA SUB-VISTA: PublicationRowView ---
// Hemos extraído la lógica de cada fila a su propia vista.
struct PublicationRowView: View {
    let publication: Publication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Cabecera con la información del autor
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
                VStack(alignment: .leading) {
                    Text(publication.authorUsername)
                        .font(.headline)
                    Text(publication.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Descripción de la publicación
            Text(publication.description)
                .lineLimit(3)
            
            // Imagen de la publicación (si existe)
            if let imageURLString = publication.imageURL, let imageURL = URL(string: imageURLString) {
                AsyncImage(url: imageURL) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // Estado de la publicación
            HStack {
                Text(publication.status.displayName)
                    .font(.caption.bold())
                    .padding(6)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Capsule())
                Spacer()
            }
        }
        .padding(.vertical)
    }
}


// --- VISTA PRINCIPAL: FeedView (Ahora mucho más simple) ---
struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @ObservedObject var authService: AuthService
    
    @State private var showingCreatePublication = false
    
    var body: some View {
        NavigationStack {
            List(viewModel.publications) { publication in
                NavigationLink(destination: PublicationDetailView(publication: publication)) {
                    // Ahora simplemente llamamos a nuestra nueva sub-vista.
                    // El código es mucho más limpio y el compilador no se quejará.
                    PublicationRowView(publication: publication)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Feed")
            .toolbar {
                Button {
                    showingCreatePublication = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $showingCreatePublication) {
                if let currentUser = authService.appUser {
                    CreatePublicationView(author: currentUser)
                }
            }
        }
    }
}
