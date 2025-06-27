//
//  PublicationDetailView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI

// --- SUB-VISTA DEDICADA PARA LA LISTA DE COMENTARIOS ---
// Esto soluciona el error del compilador y organiza el código.
struct CommentListView: View {
    @ObservedObject var viewModel: CommentsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Comentarios")
                .font(.headline)
                .padding(.bottom, 4)
            
            // --- CORRECCIÓN: Usamos 'commentThreads' en lugar de 'comments' ---
            if viewModel.commentThreads.isEmpty {
                Text("Aún no hay comentarios. ¡Sé el primero!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                // --- CORRECCIÓN: Iteramos sobre los hilos ---
                ForEach(viewModel.commentThreads) { thread in
                    // Mostramos el comentario padre
                    CommentRowView(comment: thread.parent)
                        .padding(.bottom, 8)
                    
                    // Mostramos las respuestas con una indentación
                    ForEach(thread.replies) { reply in
                        CommentRowView(comment: reply)
                            .padding(.leading, 30) // Indentación
                    }
                    Divider()
                }
            }
        }
    }
}

// --- SUB-VISTA PARA CADA FILA DE COMENTARIO ---
// Esto nos permite reutilizar el diseño para padres y respuestas.
struct CommentRowView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.authorUsername).font(.caption.bold())
                Spacer()
                Text(comment.formattedDate).font(.caption2).foregroundStyle(.secondary)
            }
            Text(comment.text).font(.callout)
            
            // Aquí podríamos añadir un botón de "Responder" en el futuro
        }
    }
}


// --- VISTA PRINCIPAL (AHORA MÁS SIMPLE Y CORRECTA) ---
struct PublicationDetailView: View {
    let publication: Publication
    let currentUser: User?
    
    @StateObject private var viewModel: CommentsViewModel

    @State private var newCommentText: String = ""
    private let publicationService = PublicationService()

    init(publication: Publication, currentUser: User?) {
        self.publication = publication
        self.currentUser = currentUser
        _viewModel = StateObject(wrappedValue: CommentsViewModel(publicationId: publication.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "person.circle.fill").font(.largeTitle).foregroundStyle(.gray)
                        VStack(alignment: .leading) {
                            Text(publication.authorUsername).font(.headline)
                            Text(publication.formattedDate).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    
                    Text(publication.description).font(.body)
                    
                    Divider()
                    
                    // Llamamos a nuestra nueva sub-vista que ya no tiene errores
                    CommentListView(viewModel: viewModel)
                }
                .padding()
            }
            
            // Campo de texto para añadir un nuevo comentario
            if currentUser != nil {
                HStack(spacing: 12) {
                    TextField("Escribe un comentario...", text: $newCommentText)
                        .textFieldStyle(.plain).padding(10)
                        .background(Color(.systemGray6)).clipShape(Capsule())
                    
                    Button { Task { await postComment() } } label: {
                        Image(systemName: "paperplane.circle.fill").font(.title)
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(.thinMaterial)
            }
        }
        .navigationTitle(publication.status.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func postComment() async {
        guard let author = currentUser, !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let commentToPost = newCommentText
        newCommentText = ""
        do {
            // Dejamos el parentId como nil para crear un comentario de primer nivel
            try await publicationService.addComment(text: commentToPost, to: publication, by: author, parentId: nil)
        } catch {
            print("Error al postear comentario: \(error)")
            newCommentText = commentToPost
        }
    }
}
