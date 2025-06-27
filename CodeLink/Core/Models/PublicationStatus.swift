//
//  PublicationStatus.swift
//  CodeLink
//
//  Created by Jamil Turpo on 25/06/25.
//


import Foundation

// Usamos un Enum para representar los posibles estados de una publicación.
// Es Codable para guardarlo en Firebase y CaseIterable para poder listarlo fácilmente.
enum PublicationStatus: String, Codable, CaseIterable {
    case help = "Ayuda"
    case info = "Informar"
    case meme = "Meme"
    
    // Propiedad para obtener el nombre legible.
    var displayName: String {
        return self.rawValue
    }
}