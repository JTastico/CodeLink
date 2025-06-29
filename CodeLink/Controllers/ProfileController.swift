//
//  ProfileController.swift
//  CodeLink
//
//  Created by Jamil Turpo on 28/06/25.
//


//
//  ProfileController.swift
//  CodeLink
//
//  Created by Jamil Turpo on 28/06/25.
//

import Foundation
import SwiftUI

@MainActor
class ProfileController: ObservableObject {
    @Published var user: User
    
    // Dependencias a los servicios del Modelo
    private let authService: AuthService
    
    // Estado de la UI
    @Published var isSaving = false
    @Published var selectedPhotoData: Data?

    init(user: User, authService: AuthService) {
        self.user = user
        self.authService = authService
    }

    func saveProfile() async throws {
        isSaving = true
        
        defer {
            isSaving = false
        }
        
        // 1. Si hay una nueva imagen, súbela primero
        if let imageData = selectedPhotoData {
            let newURL = try await authService.uploadProfileImage(imageData)
            user.profilePictureURL = newURL.absoluteString
        }

        // 2. Actualiza el perfil del usuario
        authService.updateUserProfile(user)
    }
    
    func signOut() {
        authService.signOut()
    }
}