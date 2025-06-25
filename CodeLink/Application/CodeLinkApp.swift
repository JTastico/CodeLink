//
//  CodeLinkApp.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct CodeLinkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            // --- LA CORRECCIÓN ESTÁ AQUÍ ---
            // Verificamos si existe el usuario de Firebase, no una variable 'user' genérica.
            if authService.firebaseUser != nil {
                MainView(authService: authService)
            } else {
                LoginView(authService: authService)
            }
        }
    }
}
