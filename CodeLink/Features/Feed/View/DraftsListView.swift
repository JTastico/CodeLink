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
    
    // En lugar de una @Query, usamos un @State simple para los borradores.
    @State private var drafts: [PublicationDraft] = []
    
    let currentUserId: String
    var onSelectDraft: (PublicationDraft) -> Void
    
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
            // --- LA CORRECCIÓN CLAVE ESTÁ AQUÍ ---
            // Usamos .onAppear para cargar los borradores manualmente
            // justo cuando la vista va a aparecer en pantalla.
            .onAppear(perform: fetchDrafts)
        }
    }
    
    /// Carga manualmente los borradores desde SwiftData, filtrando por el usuario actual.
    private func fetchDrafts() {
        print("DEBUG: .onAppear activado. Buscando borradores para el usuario: \(currentUserId)")
        
        // 1. Creamos la descripción de la consulta (fetch descriptor).
        let predicate = #Predicate<PublicationDraft> { draft in
            draft.authorUid == currentUserId
        }
        let sort = SortDescriptor(\PublicationDraft.createdAt, order: .reverse)
        let descriptor = FetchDescriptor<PublicationDraft>(predicate: predicate, sortBy: [sort])
        
        // 2. Ejecutamos la consulta.
        do {
            let fetchedDrafts = try modelContext.fetch(descriptor)
            print("DEBUG: ¡Éxito! Se encontraron \(fetchedDrafts.count) borradores.")
            self.drafts = fetchedDrafts
        } catch {
            print("DEBUG: ERROR FATAL al cargar los borradores manualmente: \(error.localizedDescription)")
        }
    }
    
    private func deleteDraft(at offsets: IndexSet) {
        for index in offsets {
            let draftToDelete = drafts[index]
            modelContext.delete(draftToDelete)
            
            // Forzamos un guardado explícito al eliminar también.
            do {
                try modelContext.save()
            } catch {
                print("DEBUG: Error al guardar después de eliminar: \(error.localizedDescription)")
            }
        }
        // Removemos el borrador de la lista local para que la UI se actualice al instante.
        drafts.remove(atOffsets: offsets)
    }
}
