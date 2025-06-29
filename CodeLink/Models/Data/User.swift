//
//  User.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//
import Foundation

struct User: Identifiable, Hashable, Codable {
    let id: String
    var username: String
    var fullName: String
    let email: String
    var profilePictureURL: String? // Lo haremos 'var' para poder cambiarlo
    var field: String
    var aboutMe: String? // NUEVO: Campo para la biografía
}
