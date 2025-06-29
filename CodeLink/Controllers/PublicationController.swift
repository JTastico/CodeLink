//
//  PublicationController.swift
//  CodeLink
//
//  Created by Jamil Turpo on 28/06/25.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class PublicationController: ObservableObject {
    // Estado para la creación/edición de publicaciones
    @Published var publicationDescription: String = ""
    @Published var publicationStatus: PublicationStatus = .help
    
    // --- NUEVA PROPIEDAD PARA LA IMAGEN ---
    @Published var selectedImageData: Data?
    
    // Dependencias a los servicios del Modelo
    private let publicationService = PublicationService()
    
    // Estado de la UI
    @Published var isPosting = false
    @Published var showingDrafts = false
    
    func loadFrom(draft: PublicationDraft) {
        self.publicationDescription = draft.draftDescription
        self.publicationStatus = draft.status
        self.selectedImageData = nil // Los borradores no guardan imágenes
    }

    func createPublication(author: User) async throws {
        isPosting = true
        defer { isPosting = false }
        
        try await publicationService.createPublication(
            description: publicationDescription,
            status: publicationStatus,
            imageData: selectedImageData, // Pasamos los datos de la imagen
            author: author
        )
    }

    func saveDraft(authorUid: String, modelContext: ModelContext) throws {
        let newDraft = PublicationDraft(
            description: publicationDescription,
            status: publicationStatus,
            authorUid: authorUid
        )
        
        modelContext.insert(newDraft)
        try modelContext.save()
    }
}
