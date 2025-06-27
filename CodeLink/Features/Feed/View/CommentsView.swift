//
//  CommentsView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 26/06/25.
//


import SwiftUI

struct CommentsView: View {
    let publication: Publication
    let currentUser: User
    
    @StateObject private var viewModel: CommentsViewModel
    private let publicationService = PublicationService()
    
    @State private var newCommentText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    init(publication: Publication, currentUser: User) {
        self.publication = publication
        self.currentUser = currentUser
        _viewModel = StateObject(wrappedValue: CommentsViewModel(publicationId: publication.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Comentarios")
                .font(.headline)
                .padding()
            
            Divider()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.comments) { comment in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(comment.authorUsername).font(.caption.bold())
                            Text(comment.text).font(.callout)
                            Text(comment.formattedDate).font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            HStack(spacing: 12) {
                TextField("Escribe un comentario...", text: $newCommentText)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
                    .focused($isTextFieldFocused)
                
                Button {
                    // --- TRAZA DE DEBUG AQUÍ ---
                    print("DEBUG: Botón de enviar comentario presionado.")
                    Task { await postComment() }
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .font(.title)
                }
                .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
    }
    
    private func postComment() async {
        print("DEBUG: Iniciando la función postComment en la VISTA.")
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let commentToPost = newCommentText
        newCommentText = ""
        isTextFieldFocused = false
        
        do {
            print("DEBUG: Llamando a publicationService.addComment...")
            try await publicationService.addComment(text: commentToPost, to: publication, by: currentUser)
            print("DEBUG: ¡El servicio de añadir comentario terminó sin errores!")
        } catch {
            print("DEBUG: ERROR FATAL capturado en la VISTA al postear comentario: \(error.localizedDescription)")
            // Restaura el texto si falla para que el usuario no lo pierda.
            newCommentText = commentToPost
        }
    }
}
