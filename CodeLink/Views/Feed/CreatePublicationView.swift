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
    @Environment(\.modelContext) private var modelContext
    
    let author: User
    @StateObject private var controller = PublicationController()
    
    // Estado local para el PhotosPicker
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    @FocusState private var isTextEditorFocused: Bool
    
    // Paleta de colores
    private let primaryBlue = Color(red: 0.1, green: 0.2, blue: 0.4)
    private let secondaryBlue = Color(red: 0.2, green: 0.4, blue: 0.7)
    private let accentCyan = Color(red: 0.4, green: 0.8, blue: 1.0)
    private let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.1)
    private let cardBackground = Color(red: 0.15, green: 0.25, blue: 0.4)
    
    var body: some View {
        NavigationStack {
            ZStack {
                darkBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        contentSection
                        
                        // --- SECCIÓN PARA LA IMAGEN (NUEVA) ---
                        imageSection
                        
                        statusSection
                        actionButtonsSection
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .disabled(controller.isPosting)
            .navigationTitle("Nueva Publicación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(darkBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                    .foregroundColor(.white.opacity(0.8))
                    .disabled(controller.isPosting)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if controller.isPosting {
                        ProgressView().scaleEffect(0.8).tint(accentCyan)
                    } else {
                        Button("Publicar") {
                            Task {
                                do {
                                    try await controller.createPublication(author: author)
                                    dismiss()
                                } catch {
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        }
                        .foregroundColor(controller.publicationDescription.isEmpty ? .gray : accentCyan)
                        .fontWeight(.semibold)
                        .disabled(controller.publicationDescription.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $controller.showingDrafts) {
                DraftsListView(currentUserId: author.id) { selectedDraft in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        controller.loadFrom(draft: selectedDraft)
                    }
                }
            }
            // --- OBSERVADOR PARA EL SELECTOR DE FOTOS (NUEVO) ---
            .onChange(of: selectedPhotoItem) {
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                        controller.selectedImageData = data
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            Circle().fill(primaryBlue).frame(width: 50, height: 50)
                .overlay(Text(String(author.username.prefix(1)).uppercased()).font(.title2).fontWeight(.bold).foregroundColor(accentCyan))
                .overlay(Circle().stroke(accentCyan.opacity(0.4), lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(author.username).font(.headline).fontWeight(.bold).foregroundColor(.white)
                Text("¿Qué quieres compartir?").font(.subheadline).foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentCyan.opacity(0.3), lineWidth: 1))
        )
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text").foregroundColor(accentCyan).font(.headline)
                Text("Contenido").font(.headline).fontWeight(.semibold).foregroundColor(.white)
                Spacer()
                Text("\(controller.publicationDescription.count)").font(.caption).foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(primaryBlue.opacity(0.8)))
            }
            
            TextEditor(text: $controller.publicationDescription)
                .foregroundColor(.white).font(.body).scrollContentBackground(.hidden).background(Color.clear)
                .frame(minHeight: 180).padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16).fill(primaryBlue.opacity(0.4))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isTextEditorFocused ? accentCyan : Color.white.opacity(0.2), lineWidth: 1.5))
                )
                .focused($isTextEditorFocused)
                .animation(.easeInOut(duration: 0.2), value: isTextEditorFocused)
                .overlay(
                    Group {
                        if controller.publicationDescription.isEmpty {
                            VStack {
                                HStack {
                                    Text("Describe tu proyecto, comparte tu conocimiento o pide ayuda...").foregroundColor(.white.opacity(0.5)).font(.body)
                                        .padding(.leading, 20).padding(.top, 24)
                                    Spacer()
                                }
                                Spacer()
                            }.allowsHitTesting(false)
                        }
                    }
                )
        }
        .padding(.horizontal, 20).padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(cardBackground.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(accentCyan.opacity(0.3), lineWidth: 1))
        )
    }

    // --- VISTA PREVIA DE LA IMAGEN (NUEVA) ---
    @ViewBuilder
    private var imageSection: some View {
        if let imageData = controller.selectedImageData, let uiImage = UIImage(data: imageData) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "photo.fill").foregroundColor(accentCyan)
                    Text("Imagen Adjunta").font(.headline).fontWeight(.semibold).foregroundColor(.white)
                    Spacer()
                }
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(16)
                    .overlay(
                        Button {
                            withAnimation {
                                controller.selectedImageData = nil
                                selectedPhotoItem = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding(8),
                        alignment: .topTrailing
                    )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20).fill(cardBackground.opacity(0.6))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(accentCyan.opacity(0.3), lineWidth: 1))
            )
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flag.fill").foregroundColor(accentCyan).font(.headline)
                Text("Tipo de Publicación").font(.headline).fontWeight(.semibold).foregroundColor(.white)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(PublicationStatus.allCases, id: \.self) { statusOption in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            controller.publicationStatus = statusOption
                        }
                    } label: {
                        HStack {
                            Image(systemName: iconForStatus(statusOption)).font(.title3)
                            Text(statusOption.displayName).font(.subheadline).fontWeight(.medium)
                            Spacer()
                        }
                        .foregroundColor(controller.publicationStatus == statusOption ? darkBackground : .white.opacity(0.8))
                        .padding(.horizontal, 16).padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(controller.publicationStatus == statusOption ? accentCyan : primaryBlue.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12).stroke(controller.publicationStatus == statusOption ? Color.clear : accentCyan.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .scaleEffect(controller.publicationStatus == statusOption ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: controller.publicationStatus)
                }
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(cardBackground.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(accentCyan.opacity(0.3), lineWidth: 1))
        )
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // --- BOTÓN PARA AÑADIR/CAMBIAR FOTO (NUEVO) ---
            PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                HStack {
                    Image(systemName: controller.selectedImageData == nil ? "photo.on.rectangle.angled" : "arrow.triangle.2.circlepath.camera.fill")
                        .font(.title3)
                    Text(controller.selectedImageData == nil ? "Añadir Imagen" : "Cambiar Imagen")
                        .font(.headline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16).fill(primaryBlue.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentCyan.opacity(0.4), lineWidth: 1))
                )
            }
            
            Button {
                controller.showingDrafts = true
            } label: {
                HStack {
                    Image(systemName: "tray.and.arrow.down.fill").font(.title3)
                    Text("Cargar Borrador").font(.headline).fontWeight(.medium)
                }
                .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16).fill(primaryBlue.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentCyan.opacity(0.4), lineWidth: 1))
                )
            }
            .disabled(controller.isPosting)
            
            Button {
                do {
                    try controller.saveDraft(authorUid: author.id, modelContext: modelContext)
                    dismiss()
                } catch {
                    print("Error al guardar borrador: \(error.localizedDescription)")
                }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down.fill").font(.title3)
                    Text("Guardar Borrador").font(.headline).fontWeight(.medium)
                }
                .foregroundColor(controller.publicationDescription.isEmpty ? .gray : .white)
                .frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(controller.publicationDescription.isEmpty ? Color.gray.opacity(0.3) : secondaryBlue.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16).stroke(controller.publicationDescription.isEmpty ? Color.clear : accentCyan.opacity(0.4), lineWidth: 1)
                        )
                )
            }
            .disabled(controller.publicationDescription.isEmpty || controller.isPosting)
        }
    }
    
    private func iconForStatus(_ status: PublicationStatus) -> String {
        switch status {
            case .help: return "questionmark.circle.fill"
            case .solved: return "checkmark.circle.fill"
            case .sharing: return "square.and.arrow.up.fill"
            default: return "circle.fill"
        }
    }
}
