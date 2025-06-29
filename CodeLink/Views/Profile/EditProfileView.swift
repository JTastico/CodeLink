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
    
    // La vista ahora depende del controlador
    @StateObject var controller: ProfileController
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isAnimating = false

    let fields = ["iOS Developer", "Android Developer", "Web Developer", "Backend Developer", "UI/UX Designer", "Project Manager", "QA Tester", "Tech Enthusiast"]

    // El inicializador ahora recibe el controlador
    init(controller: ProfileController) {
        _controller = StateObject(wrappedValue: controller)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryGradient
                    .ignoresSafeArea()
                    .opacity(isAnimating ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 1.5), value: isAnimating)

                ScrollView {
                    VStack(spacing: 32) {
                        profilePictureSection
                        publicFieldsSection
                        aboutMeSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                }
                .onAppear {
                    setupAnimations()
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        saveButton
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.deepBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                    .foregroundColor(Color.accentBlue)
                    .disabled(controller.isSaving)
                }
            }
            .onChange(of: selectedPhoto) {
                Task {
                    if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                        // La vista actualiza la propiedad en el controlador
                        controller.selectedPhotoData = data
                    }
                }
            }
        }
    }

    // MARK: - Secciones

    private var profilePictureSection: some View {
        VStack(spacing: 16) {
            // La vista lee los datos del controlador
            if let photoData = controller.selectedPhotoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable().scaledToFill().frame(width: 120, height: 120).clipShape(Circle())
                    .overlay(Circle().stroke(Color.accentBlue, lineWidth: 2))
                    .shadow(color: Color.accentBlue.opacity(0.5), radius: 10, x: 0, y: 5)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            } else {
                AvatarView(
                    imageURL: controller.user.profilePictureURL,
                    size: 120
                )
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            }

            PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                Text("Cambiar foto")
                    .font(.subheadline.bold())
                    .foregroundColor(Color.primaryTextColor)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(Color.glassMorphism)
                            .overlay(
                                Capsule()
                                    .stroke(Color.accentBlue.opacity(0.5), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: 20)
        .scaleEffect(isAnimating ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
    }

    private var publicFieldsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Datos Públicos")
                .font(.headline)
                .foregroundColor(Color.primaryTextColor)

            VStack(spacing: 16) {
                // Los TextFields ahora se enlazan a las propiedades del controlador
                TextField("Nombre de Usuario", text: $controller.user.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .foregroundColor(Color.primaryTextColor)
                    .background(Color.glassMorphism)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.accentBlue.opacity(0.3), lineWidth: 1))

                TextField("Nombre Completo", text: $controller.user.fullName)
                    .padding()
                    .foregroundColor(Color.primaryTextColor)
                    .background(Color.glassMorphism)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.accentBlue.opacity(0.3), lineWidth: 1))

                Picker("Especialidad", selection: $controller.user.field) {
                    ForEach(fields, id: \.self) { Text($0) }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .foregroundColor(Color.primaryTextColor)
                .background(Color.glassMorphism)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.accentBlue.opacity(0.3), lineWidth: 1))
            }
        }
        .padding()
        .glassCard(cornerRadius: 20)
        .scaleEffect(isAnimating ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
    }

    private var aboutMeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acerca de mí")
                .font(.headline)
                .foregroundColor(Color.primaryTextColor)

            ZStack(alignment: .topLeading) {
                if controller.user.aboutMe?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                    Text("Escribe algo sobre ti...")
                        .foregroundColor(Color.secondaryTextColor.opacity(0.6))
                        .padding(16)
                }

                TextEditor(text: $controller.user.aboutMe.replacingNilWithDefault())
                    .padding(14)
                    .foregroundColor(Color.primaryTextColor)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: 120)
            .background(Color.glassMorphism)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.accentBlue.opacity(0.3), lineWidth: 1))
        }
        .padding()
        .glassCard(cornerRadius: 20)
        .scaleEffect(isAnimating ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
    }

    private var saveButton: some View {
        // La acción del botón ahora llama al método del controlador
        Button(action: {
            Task {
                do {
                    try await controller.saveProfile()
                    dismiss() // Si tiene éxito, cierra la vista
                } catch {
                    print("Error al guardar el perfil: \(error.localizedDescription)")
                    // Aquí podrías mostrar una alerta al usuario
                }
            }
        }) {
            HStack {
                if controller.isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.primaryTextColor))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                }
                Text(controller.isSaving ? "Guardando..." : "Guardar Cambios")
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .foregroundColor(Color.primaryTextColor)
            .background(
                Capsule()
                    .fill(Color.accentGradient)
                    .shadow(color: Color.accentBlue.opacity(0.3), radius: 10, x: 0, y: 6)
            )
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(controller.isSaving)
        .scaleEffect(controller.isSaving ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: controller.isSaving)
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
    }

    private func setupAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = true
        }
    }
}

// MARK: - Extensión útil
// Esta extensión puede permanecer o moverse a un archivo de utilidades
extension Binding where Value == String? {
    func replacingNilWithDefault() -> Binding<String> {
        return Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { self.wrappedValue = $0 }
        )
    }
}
