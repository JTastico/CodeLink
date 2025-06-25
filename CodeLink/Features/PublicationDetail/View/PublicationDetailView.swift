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
                // Contenido de la publicación
                VStack(alignment: .leading, spacing: 8) {
                    Text(publication.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Preguntado por \(publication.author.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                Text(publication.body)
                    .font(.body)
                
                Divider()
                
                // Sección de Respuestas
                Text("Respuestas (\(publication.comments.count))")
                    .font(.headline)
                
                ForEach(publication.comments) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comment.text)
                        Text("— \(comment.author.fullName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
    }
}