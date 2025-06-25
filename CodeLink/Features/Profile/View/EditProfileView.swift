//
//  EditProfileView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//


import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var user: User
    var authService: AuthService
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    @State private var isSaving = false
    
    let fields = ["iOS Developer", "Android Developer", "Web Developer", "Backend Developer", "UI/UX Designer", "Project Manager", "QA Tester", "Tech Enthusiast"]
    
    init(user: User, authService: AuthService) {
        _user = State(initialValue: user)
        self.authService = authService
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Foto de Perfil") {
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            if let selectedPhotoData, let uiImage = UIImage(data: selectedPhotoData) {
                                Image(uiImage: uiImage)
                                    .resizable().scaledToFill().frame(width: 100, height: 100).clipShape(Circle())
                            } else {
                                AsyncImage(url: URL(string: user.profilePictureURL ?? "")) { image in
                                    image.resizable().scaledToFill().frame(width: 100, height: 100).clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.crop.circle.fill").font(.system(size: 100)).foregroundStyle(.gray)
                                }
                            }
                            PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                                Text("Cambiar foto")
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section("Datos Públicos") {
                    TextField("Nombre de Usuario", text: $user.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Nombre Completo", text: $user.fullName)
                    
                    Picker("Especialidad", selection: $user.field) {
                        ForEach(fields, id: \.self) { field in
                            Text(field)
                        }
                    }
                }
                
                Section("Acerca de mí") {
                    TextEditor(text: $user.aboutMe.replacingNilWithDefault())
                        .frame(height: 100)
                }
            }
            .disabled(isSaving)
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }.disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Guardar") {
                            // Envolvemos la llamada en un Task para ejecutar código asíncrono
                            Task {
                                await saveProfile()
                            }
                        }
                    }
                }
            }
            .onChange(of: selectedPhoto) {
                Task {
                    if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                        self.selectedPhotoData = data
                    }
                }
            }
        }
    }
    
    // --- FUNCIÓN DE GUARDADO CORREGIDA CON ASYNC/AWAIT ---
    func saveProfile() async {
        isSaving = true
        
        do {
            // Si el usuario seleccionó datos de una nueva imagen...
            if let imageData = selectedPhotoData {
                // ...usamos 'try await' para llamar a la función asíncrona y esperar el resultado.
                let newURL = try await authService.uploadProfileImage(imageData)
                // Actualizamos la URL en nuestra copia local del usuario.
                user.profilePictureURL = newURL.absoluteString
            }
            
            // Ahora, con la URL correcta (la vieja o la nueva), guardamos el perfil completo.
            authService.updateUserProfile(user)
            
            // Y finalmente, cerramos la vista.
            dismiss()
            
        } catch {
            print("Error al guardar el perfil: \(error.localizedDescription)")
            // Si hay un error, dejamos de guardar para que el usuario pueda reintentar.
            isSaving = false
        }
    }
}


// La extensión se queda igual
extension Binding where Value == String? {
    func replacingNilWithDefault() -> Binding<String> {
        return Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { self.wrappedValue = $0 }
        )
    }
}

// El Preview se queda igual
#Preview {
    let sampleUser = User(id: "preview123", username: "preview_user", fullName: "Preview Name", email: "preview@test.com", profilePictureURL: nil, field: "SwiftUI Expert", aboutMe: "Bio de ejemplo.")
    return EditProfileView(user: sampleUser, authService: AuthService())
}
