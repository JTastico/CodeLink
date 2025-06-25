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
            if authService.user != nil {
                // ANTES: MainView().environmentObject(authService)
                // AHORA: Le pasamos el servicio directamente
                MainView(authService: authService)
            } else {
                // ANTES: LoginView().environmentObject(authService)
                // AHORA: Le pasamos el servicio directamente
                LoginView(authService: authService)
            }
        }
    }
}
