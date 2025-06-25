//
//  AuthService.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//


import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn

class AuthService: ObservableObject {
    
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var appUser: User?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var userProfileHandle: DatabaseHandle?
    private var dbRef: DatabaseReference = Database.database().reference()
    private var storageRef: StorageReference = Storage.storage().reference()

    init() {
        addStateListener()
    }
    
    deinit {
        removeStateListener()
        removeUserProfileListener()
    }
    
    private func addStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            DispatchQueue.main.async {
                self?.firebaseUser = user
                if let firebaseUser = user {
                    self?.listenForUserProfileChanges(userId: firebaseUser.uid)
                } else {
                    self?.removeUserProfileListener()
                    self?.appUser = nil
                }
            }
        }
    }
    
    private func listenForUserProfileChanges(userId: String) {
        let userRef = dbRef.child("users").child(userId)
        self.userProfileHandle = userRef.observe(.value) { [weak self] snapshot in
            if snapshot.exists(), let userData = snapshot.value as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: userData)
                    let userProfile = try JSONDecoder().decode(User.self, from: jsonData)
                    self?.appUser = userProfile
                } catch { print("Error al decodificar perfil de usuario en tiempo real: \(error)") }
            } else {
                self?.createUserProfileIfNeeded(for: userId)
            }
        }
    }
    
    private func createUserProfileIfNeeded(for userId: String) {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        let newUser = User(
            id: firebaseUser.uid,
            username: firebaseUser.email?.components(separatedBy: "@").first ?? "nuevo_usuario",
            fullName: firebaseUser.displayName ?? "Sin Nombre",
            email: firebaseUser.email ?? "Sin Email",
            profilePictureURL: firebaseUser.photoURL?.absoluteString,
            field: "Tech Enthusiast",
            aboutMe: "¡Hola! Soy nuevo en CodeLink."
        )
        updateUserProfile(newUser)
    }

    private func removeStateListener() {
        if let authStateHandle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }
    
    private func removeUserProfileListener() {
        guard let userProfileHandle = userProfileHandle, let userId = firebaseUser?.uid else { return }
        let userRef = dbRef.child("users").child(userId)
        userRef.removeObserver(withHandle: userProfileHandle)
    }

    func updateUserProfile(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            let json = try JSONSerialization.jsonObject(with: data)
            dbRef.child("users").child(user.id).setValue(json)
        } catch {
            print("Error al guardar perfil de usuario: \(error)")
        }
    }
    
    // --- FUNCIÓN DE SUBIR IMAGEN REESCRITA CON ASYNC/AWAIT ---
    func uploadProfileImage(_ imageData: Data) async throws -> URL {
        guard let userId = firebaseUser?.uid else {
            throw URLError(.badURL) // Lanza un error si no hay ID de usuario
        }
        
        let profilePicRef = storageRef.child("profile_pictures/\(userId).jpg")
        
        // El nuevo método 'putDataAsync' espera a que la subida termine
        let _ = try await profilePicRef.putDataAsync(imageData)
        
        // El nuevo método 'downloadURL()' también espera a obtener la URL
        let downloadURL = try await profilePicRef.downloadURL()
        
        return downloadURL
    }
    
    // --- El resto de los métodos de Login y Logout se quedan igual ---
    // (Asegúrate de que estén aquí)
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first, let rootViewController = window.rootViewController else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard error == nil, let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            self?.authenticate(with: credential)
        }
    }
    func signInWithGitHub() {
        let provider = OAuthProvider(providerID: "github.com")
        provider.getCredentialWith(nil) { [weak self] credential, error in
            guard let credential = credential, error == nil else { return }
            self?.authenticate(with: credential)
        }
    }
    private func authenticate(with credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { _, error in
            if let error = error { print("Error al autenticar en Firebase: \(error.localizedDescription)") }
        }
    }
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do { try Auth.auth().signOut() }
        catch { print("Error al cerrar sesión en Firebase: \(error.localizedDescription)") }
    }
}
