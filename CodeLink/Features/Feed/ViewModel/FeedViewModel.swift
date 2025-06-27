//
//  FeedViewModel.swift
//  CodeLink
//
//  Created by Jamil Turpo on 25/06/25.
//

import Foundation
import FirebaseDatabase

@MainActor // Asegura que las actualizaciones de la UI se hagan en el hilo principal.
class FeedViewModel: ObservableObject {
    
    @Published var publications: [Publication] = []
    private let publicationService = PublicationService()
    private var publicationsListenerHandle: DatabaseHandle?
    
    init() {
        startListeningForPublications()
    }
    
    deinit {
        // Cuando el ViewModel se destruye, dejamos de escuchar para liberar memoria.
        if let handle = publicationsListenerHandle {
            publicationService.removeListener(with: handle)
        }
    }
    
    func startListeningForPublications() {
        // Empezamos a escuchar los cambios y actualizamos nuestra lista de publicaciones.
        publicationsListenerHandle = publicationService.listenForPublications { [weak self] newPublications in
            self?.publications = newPublications
        }
    }
}
