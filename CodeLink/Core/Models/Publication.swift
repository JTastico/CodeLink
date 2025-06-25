//
//  Publication.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import Foundation

struct Publication: Identifiable, Hashable {
    let id = UUID()
    let author: User
    let title: String
    let body: String
    let votes: Int
    let comments: [Comment]
    
    static var sampleData: [Publication] = [
        Publication(author: User.example, title: "¿Cómo centrar un `VStack` dentro de un `HStack` en SwiftUI?", body: "He intentado de todo, con Spacers y paddings pero no logro que el VStack se centre verticalmente de forma correcta cuando el contenido del HStack es dinámico.", votes: 42, comments: Comment.sampleData),
        Publication(author: .example, title: "Error de 'fatal error: unexpectedly found nil while unwrapping an Optional value'", body: "Sé que esto significa que un opcional es nil, pero en mi código no logro ver dónde está el error. Adjunto el fragmento de código que me da problemas...", votes: 15, comments: []),
        Publication(author: .example, title: "¿Cuál es la mejor manera de manejar la concurrencia en Swift 6?", body: "Con los nuevos cambios en el modelo de actores y `Sendable`, ¿cuál es la práctica recomendada para realizar múltiples llamadas de red de forma segura y eficiente?", votes: 123, comments: [])
    ]
}
