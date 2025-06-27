//
//  CreatePublicationView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 25/06/25.
//

import SwiftUI
import PhotosUI

struct CreatePublicationView: View {
    @Environment(\.dismiss) var dismiss
    
    private let publicationService = PublicationService()
    let author: User
    
    @State private var description: String = ""
    @State private var status: PublicationStatus = .help
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    @State private var isPosting = false
    
    var body: some View {
        NavigationStack {
            // --- FORMULARIO CON TODO EL CONTENIDO ---
            Form {
                Section("Contenido de la Publicación") {
                    // Campo de texto para la descripción
                    TextEditor(text: $description)
                        .frame(minHeight: 150)
                        .padding(4)
                    
                    // Selector para el estado de la publicación
                    Picker("Estado", selection: $status) {
                        ForEach(PublicationStatus.allCases, id: \.self) { status in
                            Text(status.displayName)
                        }
                    }
                }
                
                Section("Imagen (Opcional)") {
                    // Mostramos la imagen seleccionada si existe
                    if let selectedPhotoData, let uiImage = UIImage(data: selectedPhotoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Botón para abrir el selector de fotos
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Label("Seleccionar una foto", systemImage: "photo.on.rectangle.angled")
                    }
                }
            }
            .disabled(isPosting)
            .navigationTitle("Nueva Publicación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }.disabled(isPosting)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isPosting {
                        ProgressView()
                    } else {
                        Button("Publicar") {
                            Task { await createPublication() }
                        }
                        // El botón se deshabilita si no hay descripción
                        .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .onChange(of: selectedPhoto) {
                // Cargamos los datos de la foto seleccionada
                Task {
                    if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                        selectedPhotoData = data
                    }
                }
            }
        }
    }
    
    private func createPublication() async {
        isPosting = true
        do {
            try await publicationService.createPublication(
                description: description,
                status: status,
                imageData: selectedPhotoData,
                author: author
            )
            // Si todo sale bien, cerramos la vista
            dismiss()
        } catch {
            print("Error al crear la publicación desde la vista: \(error.localizedDescription)")
            // Aquí podrías mostrar una alerta al usuario
            isPosting = false
        }
    }
}

// Vista previa para el lienzo de Xcode
#Preview {
    let sampleUser = User(id: "previewUser", username: "preview", fullName: "Preview User", email: "preview@test.com", profilePictureURL: nil, field: "Previewer", aboutMe: nil)
    return CreatePublicationView(author: sampleUser)
}
