//
//  CreatePublicationView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 25/06/25.
//

import SwiftUI
import PhotosUI

struct CreatePublicationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private let publicationService = PublicationService()
    let author: User
    
    @State private var description: String = ""
    @State private var status: PublicationStatus = .help
    @State private var isPosting = false
    
    @State private var showingDrafts = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Contenido de la Publicación") {
                    TextEditor(text: $description)
                        .frame(minHeight: 150)
                    
                    Picker("Estado", selection: $status) {
                        ForEach(PublicationStatus.allCases, id: \.self) { status in Text(status.displayName) }
                    }
                }
            }
            .disabled(isPosting)
            .navigationTitle("Nueva Publicación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }.disabled(isPosting)
                }
                
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button("Guardar Borrador") {
                        saveDraft()
                    }.disabled(description.isEmpty || isPosting)
                    
                    if isPosting {
                        ProgressView()
                    } else {
                        Button("Publicar") {
                            Task { await createPublication() }
                        }.disabled(description.isEmpty)
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        showingDrafts = true
                    } label: {
                        Label("Cargar Borrador", systemImage: "tray.and.arrow.down.fill")
                    }
                    Spacer()
                }
            }
            // --- LA CORRECCIÓN ESTÁ AQUÍ ---
            .sheet(isPresented: $showingDrafts) {
                // Hacemos explícito el nombre del parámetro 'onSelectDraft'
                // para evitar la ambigüedad.
                DraftsListView(currentUserId: author.id, onSelectDraft: { selectedDraft in
                    self.description = selectedDraft.draftDescription
                    self.status = selectedDraft.status
                })
            }
        }
    }
    
    private func saveDraft() {
        let newDraft = PublicationDraft(description: description, status: status, authorUid: author.id)
        modelContext.insert(newDraft)
        dismiss()
    }
    
    private func createPublication() async {
        isPosting = true
        do {
            try await publicationService.createPublication(description: description, status: status, imageData: nil, author: author)
            dismiss()
        } catch {
            print("Error al crear la publicación: \(error.localizedDescription)")
            isPosting = false
        }
    }
}
