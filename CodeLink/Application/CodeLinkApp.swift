//
//  CodeLinkApp.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import SwiftUI
import FirebaseCore
import SwiftData

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
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            let container = try ModelContainer(for: PublicationDraft.self)
            self.modelContainer = container
            DraftService.shared.configure(with: container)
        } catch {
            fatalError("No se pudo inicializar el ModelContainer.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if authService.firebaseUser != nil {
                MainView(authService: authService)
            } else {
                LoginView(authService: authService)
            }
        }
        .modelContainer(modelContainer)
    }
}
