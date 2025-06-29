//
//  PublicationDraft.swift
//  CodeLink
//
//  Created by Jamil Turpo on 27/06/25.
//

import Foundation
import SwiftData

@Model
final class PublicationDraft {
    @Attribute(.unique) var id: UUID
    var authorUid: String
    var draftDescription: String
    var createdAt: Date
    
    // --- LA CORRECCIÓN ESTÁ AQUÍ ---
    // 1. Guardamos el 'rawValue' del enum, que es un String.
    // SwiftData maneja los Strings de forma nativa y sin problemas.
    private var statusRawValue: String
    
    // 2. Creamos una propiedad computada para usar el enum cómodamente en el código.
    // Esta propiedad NO se guarda en la base de datos, solo calcula su valor.
    var status: PublicationStatus {
        get {
            // Al LEER, convertimos el String guardado de vuelta a nuestro enum.
            // Si por alguna razón falla, devolvemos .help como valor por defecto.
            return PublicationStatus(rawValue: statusRawValue) ?? .help
        }
        set {
            // Al ESCRIBIR, guardamos el rawValue del nuevo valor que nos pasen.
            self.statusRawValue = newValue.rawValue
        }
    }
    
    init(description: String, status: PublicationStatus, authorUid: String) {
        self.id = UUID()
        self.draftDescription = description
        self.createdAt = Date()
        self.authorUid = authorUid
        
        // 3. En el inicializador, nos aseguramos de guardar el rawValue.
        self.statusRawValue = status.rawValue
    }
}
