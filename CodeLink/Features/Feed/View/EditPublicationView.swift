//
//  EditPublicationView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 26/06/25.
//


import SwiftUI

struct EditPublicationView: View {
    @Environment(\.dismiss) var dismiss
    
    // Usamos @Binding para que los cambios que se hagan aquí
    // se reflejen inmediatamente en la vista del Feed.
    @Binding var publication: Publication
    
    private let publicationService = PublicationService()
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Contenido de la Publicación") {
                    TextEditor(text: $publication.description)
                        .frame(minHeight: 150)
                    
                    Picker("Estado", selection: $publication.status) {
                        ForEach(PublicationStatus.allCases, id: \.self) { status in
                            Text(status.displayName)
                        }
                    }
                }
            }
            .disabled(isSaving)
            .navigationTitle("Editar Publicación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Guardar") {
                            Task { await saveChanges() }
                        }
                    }
                }
            }
        }
    }
    
    private func saveChanges() async {
        isSaving = true
        do {
            try await publicationService.updatePublication(publication)
            dismiss()
        } catch {
            print("Error al guardar los cambios: \(error.localizedDescription)")
            isSaving = false
        }
    }
}
