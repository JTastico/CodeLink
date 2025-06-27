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
    
    // El contenedor de SwiftData
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Creamos el contenedor
            let container = try ModelContainer(for: PublicationDraft.self)
            self.modelContainer = container
            
            // --- LA CORRECCIÓN ESTÁ AQUÍ ---
            // Llamamos a la configuración del servicio directamente, SIN el 'Task'.
            // La función 'configure' está marcada como @MainActor, así que es seguro llamarla aquí.
            DraftService.shared.configure(with: container)
            
        } catch {
            // Si la base de datos local no se puede crear, la app no puede continuar.
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
        // Pasamos el contenedor a toda la app para que esté disponible en el entorno.
        .modelContainer(modelContainer)
    }
}
