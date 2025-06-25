//
//  FeedView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//


import SwiftUI

struct FeedView: View {
    // Esta vista NO necesita el authService por ahora
    
    let publications = Publication.sampleData
    
    var body: some View {
        NavigationStack {
            List(publications) { publication in
                NavigationLink(value: publication) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(publication.title)
                            .font(.headline)
                        
                        HStack {
                            Text("por \(publication.author.username)")
                            Spacer()
                            Text("\(publication.votes) votos")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Feed")
            .navigationDestination(for: Publication.self) { publication in
                PublicationDetailView(publication: publication)
            }
        }
    }
}

// El Preview de esta vista es simple
#Preview {
    FeedView()
}
