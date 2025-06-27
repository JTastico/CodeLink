//
//  PublicationDetailView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

struct PublicationDetailView: View {
    let publication: Publication
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // --- Cabecera con la información del autor ---
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
                
                // --- Muestra la imagen si existe ---
                if let imageURLString = publication.imageURL, let imageURL = URL(string: imageURLString) {
                    AsyncImage(url: imageURL) { image in
                        image.resizable()
                             .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                // --- Muestra la descripción ---
                Text(publication.description)
                    .font(.body)
                
                Divider()
                
                // --- Sección para los comentarios (futuro) ---
                Text("Comentarios")
                    .font(.headline)
                
                // Aquí iría la lista de comentarios
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(publication.status.displayName) // El título ahora es el estado
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // Creamos una publicación de ejemplo para que la vista previa funcione
    let sampleAuthor = User(id: "123", username: "preview_user", fullName: "Preview Name", email: "preview@test.com", profilePictureURL: nil, field: "iOS Developer", aboutMe: nil)
    let samplePublication = Publication(id: "abc", authorUid: "123", authorUsername: "preview_user", description: "Esta es una descripción de ejemplo para la vista previa. Aquí iría el contenido detallado de la publicación.", imageURL: nil, createdAt: Date().timeIntervalSince1970, status: .help, likes: 0)
    
    // Devolvemos la vista dentro de un NavigationStack para ver el título
    return NavigationStack {
        PublicationDetailView(publication: samplePublication)
    }
}
