//
//  DraftService.swift
//  CodeLink
//
//  Created by Jamil Turpo on 27/06/25.
//


import Foundation
import SwiftData

/// Un servicio centralizado para manejar todas las operaciones de SwiftData para los borradores.
/// Usa el patrón Singleton para asegurar una única instancia en toda la app.
class DraftService {
    
    static let shared = DraftService()
    
    @MainActor
    var modelContext: ModelContext? {
        guard let container = modelContainer else { return nil }
        return container.mainContext
    }
    
    private var modelContainer: ModelContainer?
    
    private init() {}
    
    /// Configura el servicio con el contenedor principal de la app.
    /// Debe ser llamado una sola vez, cuando la app arranca.
    @MainActor
    func configure(with container: ModelContainer) {
        if self.modelContainer == nil {
            self.modelContainer = container
        }
    }
    
    /// Guarda un nuevo borrador en la base de datos.
    @MainActor func saveDraft(description: String, status: PublicationStatus, authorUid: String) throws {
        guard let context = modelContext else {
            print("Error: El contexto del modelo no está disponible.")
            return
        }
        
        let newDraft = PublicationDraft(description: description, status: status, authorUid: authorUid)
        context.insert(newDraft)
        
        // Forzamos el guardado explícito
        try context.save()
        print("DraftService: Borrador guardado exitosamente para el autor \(authorUid)")
    }
    
    /// Obtiene todos los borradores para un usuario específico.
    @MainActor func fetchDrafts(for userId: String) -> [PublicationDraft] {
        guard let context = modelContext else {
            print("Error: El contexto del modelo no está disponible para la búsqueda.")
            return []
        }
        
        let predicate = #Predicate<PublicationDraft> { draft in
            draft.authorUid == userId
        }
        let sort = SortDescriptor(\PublicationDraft.createdAt, order: .reverse)
        let descriptor = FetchDescriptor<PublicationDraft>(predicate: predicate, sortBy: [sort])
        
        do {
            let drafts = try context.fetch(descriptor)
            print("DraftService: Se encontraron \(drafts.count) borradores para el usuario \(userId)")
            return drafts
        } catch {
            print("DraftService: Error al obtener los borradores: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Elimina un borrador específico.
    @MainActor func deleteDraft(_ draft: PublicationDraft) throws {
        guard let context = modelContext else { return }
        context.delete(draft)
        try context.save()
        print("DraftService: Borrador eliminado exitosamente.")
    }
}
