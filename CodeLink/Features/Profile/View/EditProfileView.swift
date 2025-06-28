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

    // Paleta de colores consistente
    private let primaryDark = Color(red: 0.05, green: 0.08, blue: 0.15)
    private let secondaryDark = Color(red: 0.08, green: 0.12, blue: 0.20)
    private let accentBlue = Color(red: 0.20, green: 0.50, blue: 0.85)
    private let lightBlue = Color(red: 0.40, green: 0.70, blue: 0.95)
    private let pureBlack = Color(red: 0.02, green: 0.02, blue: 0.05)
    private let softWhite = Color.white.opacity(0.95)
    private let glass = Color.white.opacity(0.08)


    init(user: User, authService: AuthService) {
        _user = State(initialValue: user)
        self.authService = authService
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo gradiente
                LinearGradient(colors: [pureBlack, primaryDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        profilePictureSection
                        publicFieldsSection
                        aboutMeSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                }

                // Botón de guardar flotante
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Editar Perfil")
                        .font(.title2.bold())
                        .foregroundColor(Color.white.opacity(0.95)) // softWhite
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }.disabled(isSaving)
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

    // MARK: - Secciones

    private var profilePictureSection: some View {
        VStack(spacing: 16) {
            if let selectedPhotoData, let uiImage = UIImage(data: selectedPhotoData) {
                Image(uiImage: uiImage)
                    .resizable().scaledToFill().frame(width: 120, height: 120).clipShape(Circle())
            } else {
                AsyncImage(url: URL(string: user.profilePictureURL ?? "")) { image in
                    image.resizable().scaledToFill().frame(width: 120, height: 120).clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.gray)
                }
            }

            PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                Text("Cambiar Foto")
                    .font(.subheadline)
                    .foregroundColor(lightBlue)
                    .underline()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(secondaryDark.opacity(0.5))
                .background(RoundedRectangle(cornerRadius: 20).fill(glass))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(lightBlue.opacity(0.2), lineWidth: 1))
        )
    }

    private var publicFieldsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Datos Públicos")
                .font(.headline)
                .foregroundColor(softWhite)

            VStack(spacing: 16) {
                TextField("Nombre de Usuario", text: $user.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(roundedField)

                TextField("Nombre Completo", text: $user.fullName)
                    .padding()
                    .background(roundedField)

                Picker("Especialidad", selection: $user.field) {
                    ForEach(fields, id: \.self) { Text($0) }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(roundedField)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(secondaryDark.opacity(0.5))
                .background(RoundedRectangle(cornerRadius: 20).fill(glass))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(lightBlue.opacity(0.2), lineWidth: 1))
        )
    }

    private var aboutMeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acerca de mí")
                .font(.headline)
                .foregroundColor(softWhite)

            ZStack(alignment: .topLeading) {
                if user.aboutMe?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                    Text("Escribe algo sobre ti...")
                        .foregroundColor(softWhite.opacity(0.4))
                        .padding(16)
                }

                TextEditor(text: $user.aboutMe.replacingNilWithDefault())
                    .padding(14)
                    .foregroundColor(softWhite)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(secondaryDark.opacity(0.5))
                    .background(RoundedRectangle(cornerRadius: 20).fill(glass))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lightBlue.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(secondaryDark.opacity(0.5))
                .background(RoundedRectangle(cornerRadius: 20).fill(glass))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(lightBlue.opacity(0.2), lineWidth: 1))
        )
    }

    private var saveButton: some View {
        Button(action: { Task { await saveProfile() } }) {
            HStack {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: softWhite))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                }

                Text(isSaving ? "Guardando..." : "Guardar Cambios")
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .foregroundColor(softWhite)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(colors: [lightBlue, accentBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: lightBlue.opacity(0.3), radius: 10, x: 0, y: 6)
            )
        }
        .disabled(isSaving)
        .scaleEffect(isSaving ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSaving)
    }

    private var roundedField: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(secondaryDark.opacity(0.4))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lightBlue.opacity(0.15), lineWidth: 1)
            )
    }

    // MARK: - Guardado
    func saveProfile() async {
        isSaving = true
        do {
            if let imageData = selectedPhotoData {
                let newURL = try await authService.uploadProfileImage(imageData)
                user.profilePictureURL = newURL.absoluteString
            }

            authService.updateUserProfile(user)
            dismiss()
        } catch {
            print("Error al guardar el perfil: \(error.localizedDescription)")
            isSaving = false
        }
    }
}

// MARK: - Extensión útil
extension Binding where Value == String? {
    func replacingNilWithDefault() -> Binding<String> {
        return Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { self.wrappedValue = $0 }
        )
    }
}

// MARK: - Preview
#Preview {
    let sampleUser = User(id: "preview123", username: "preview_user", fullName: "Preview Name", email: "preview@test.com", profilePictureURL: nil, field: "iOS Developer", aboutMe: "")
    return EditProfileView(user: sampleUser, authService: AuthService())
}
