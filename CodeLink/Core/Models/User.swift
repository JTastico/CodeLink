//
//  User.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//
import Foundation

struct User: Identifiable, Hashable {
    let id = UUID()
    let username: String
    let fullName: String
    let profilePicture: String // Usaremos nombres de SF Symbols por ahora
    let field: String // "Frontend", "Backend", etc.
    
    static var example = User(username: "johndoe", fullName: "John Doe", profilePicture: "person.crop.circle.fill", field: "iOS Developer")
}
