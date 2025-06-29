//
//  PublicationController.swift
//  CodeLink
//
//  Created by Jamil Turpo on 28/06/25.
//


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
    
    // Dependencias a los servicios del Modelo
    private let publicationService = PublicationService()
    
    // Estado de la UI
    @Published var isPosting = false
    @Published var showingDrafts = false
    
    func loadFrom(draft: PublicationDraft) {
        self.publicationDescription = draft.draftDescription
        self.publicationStatus = draft.status
    }

    func createPublication(author: User) async throws {
        isPosting = true
        defer { isPosting = false }
        
        try await publicationService.createPublication(
            description: publicationDescription,
            status: publicationStatus,
            imageData: nil, // Puedes añadir lógica para imágenes aquí
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