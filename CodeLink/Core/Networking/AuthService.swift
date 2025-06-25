//
//  AuthService.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AuthService: ObservableObject {
    
    // Publicamos el usuario de Firebase directamente.
    // La vista reaccionará cuando este cambie (de nil a un valor, o viceversa).
    @Published var user: FirebaseAuth.User?
    
    // Guardamos una referencia al "oyente" para poder quitarlo después
    // y evitar fugas de memoria.
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // En cuanto se crea el servicio, empezamos a escuchar los cambios.
        addStateListener()
    }
    
    deinit {
        // Es una buena práctica quitar el oyente cuando el objeto se destruye.
        removeStateListener()
    }
    
    /// Se suscribe a los cambios de estado de autenticación de Firebase.
    private func addStateListener() {
        // addStateDidChangeListener es el método clásico.
        // Se le pasa un closure (bloque de código) que se ejecutará
        // cada vez que un usuario inicie o cierre sesión.
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            // Nos aseguramos de que la actualización de la variable @Published
            // se haga en el hilo principal, ya que afectará a la UI.
            DispatchQueue.main.async {
                self?.user = user
            }
        }
    }
    
    /// Deja de escuchar los cambios de estado.
    private func removeStateListener() {
        if let authStateHandle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }
    
    func signInWithGoogle() {
        // Obtenemos el ID de cliente de nuestro .plist
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error: No se encontró el clientID de Firebase.")
            return
        }
        
        // Creamos la configuración de Google Sign In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Obtenemos la ventana principal para presentar el flujo de login
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("Error: No se pudo encontrar la ventana principal.")
            return
        }

        // Iniciamos el flujo de Google Sign In
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard error == nil, let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("Error en Google Sign In: \(error?.localizedDescription ?? "N/A")")
                return
            }
            
            // Creamos la credencial de Firebase con el token de Google
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: user.accessToken.tokenString)
            
            // Autenticamos en Firebase
            self?.authenticate(with: credential)
        }
    }
    
    func signInWithGitHub() {
        let provider = OAuthProvider(providerID: "github.com")
        
        provider.getCredentialWith(nil) { [weak self] credential, error in
            guard let credential = credential, error == nil else {
                print("Error en GitHub Sign In: \(error?.localizedDescription ?? "N/A")")
                return
            }
            // Autenticamos en Firebase
            self?.authenticate(with: credential)
        }
    }
    
    private func authenticate(with credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print("Error al autenticar en Firebase: \(error.localizedDescription)")
            }
            // No necesitamos hacer nada más aquí.
            // El 'addStateDidChangeListener' se encargará automáticamente
            // de detectar el cambio y actualizar la variable 'user'.
        }
    }
    
    func signOut() {
        // Cerramos sesión en Google Sign In para que permita elegir otra cuenta la próxima vez.
        GIDSignIn.sharedInstance.signOut()
        
        // Cerramos sesión en Firebase.
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error al cerrar sesión en Firebase: \(error.localizedDescription)")
        }
    }
}
