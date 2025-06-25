//
//  Comment.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import Foundation

struct Comment: Identifiable, Hashable {
    let id = UUID()
    let author: User
    let text: String
    
    static var sampleData: [Comment] = [
        Comment(author: User.example, text: "¡Gran pregunta! Intenta invalidar el layout del CollectionView."),
        Comment(author: User(username: "janedev", fullName: "Jane Dev", profilePicture: "person.crop.circle", field: "Android Developer"), text: "A mí me pasó lo mismo, la solución es usar un `GeometryReader` para obtener el tamaño del contenedor padre.")
    ]
}
