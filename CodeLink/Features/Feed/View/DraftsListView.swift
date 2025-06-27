//
//  DraftsListView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 27/06/25.
//


import SwiftUI
import SwiftData

struct DraftsListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // La consulta @Query ahora se configura en el inicializador para poder filtrar.
    @Query private var drafts: [PublicationDraft]
    
    var onSelectDraft: (PublicationDraft) -> Void
    
    // --- INICIALIZADOR PERSONALIZADO PARA FILTRAR ---
    // Este es el cambio clave para que cada usuario solo vea sus borradores.
    init(currentUserId: String, onSelectDraft: @escaping (PublicationDraft) -> Void) {
        self.onSelectDraft = onSelectDraft
        
        // Creamos un "predicado" o filtro para la consulta.
        // Le decimos a SwiftData: "dame solo los borradores cuyo 'authorUid'
        // sea igual al ID del usuario actual".
        let predicate = #Predicate<PublicationDraft> { draft in
            draft.authorUid == currentUserId
        }
        
        // Configuramos la consulta @Query con el filtro y el orden.
        _drafts = Query(filter: predicate, sort: \.createdAt, order: .reverse)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if drafts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "pencil.and.scribble")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        Text("No tienes borradores guardados.")
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(drafts) { draft in
                            Button {
                                onSelectDraft(draft)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(draft.draftDescription)
                                        .lineLimit(2)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text("Guardado: \(draft.createdAt, format: .relative(presentation: .named))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteDraft)
                    }
                }
            }
            .navigationTitle("Borradores")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
    
    private func deleteDraft(at offsets: IndexSet) {
        for index in offsets {
            let draftToDelete = drafts[index]
            modelContext.delete(draftToDelete)
        }
    }
}
