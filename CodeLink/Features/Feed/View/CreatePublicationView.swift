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
    
    private let publicationService = PublicationService()
    let author: User
    
    @State private var description: String = ""
    @State private var status: PublicationStatus = .help
    @State private var isPosting = false
    @State private var showingDrafts = false
    @FocusState private var isTextEditorFocused: Bool
    
    // Paleta de colores sin degradados
    private let primaryBlue = Color(red: 0.1, green: 0.2, blue: 0.4)       // Azul oscuro
    private let secondaryBlue = Color(red: 0.2, green: 0.4, blue: 0.7)     // Azul medio
    private let accentCyan = Color(red: 0.4, green: 0.8, blue: 1.0)        // Celeste
    private let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.1)  // Negro azulado
    private let cardBackground = Color(red: 0.15, green: 0.25, blue: 0.4)  // Azul oscuro para tarjetas
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo principal sólido
                darkBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header con avatar del usuario
                        headerSection
                        
                        // Editor de contenido
                        contentSection
                        
                        // Selector de estado
                        statusSection
                        
                        // Botones de acción
                        actionButtonsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .disabled(isPosting)
            .navigationTitle("Nueva Publicación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(darkBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .disabled(isPosting)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if isPosting {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(accentCyan)
                    } else {
                        Button("Publicar") {
                            Task { await createPublication() }
                        }
                        .foregroundColor(description.isEmpty ? .gray : accentCyan)
                        .fontWeight(.semibold)
                        .disabled(description.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showingDrafts) {
                DraftsListView(currentUserId: author.id) { selectedDraft in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.description = selectedDraft.draftDescription
                        self.status = selectedDraft.status
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            // Avatar del usuario
            Circle()
                .fill(primaryBlue)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(author.username.prefix(1)).uppercased())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(accentCyan)
                )
                .overlay(
                    Circle()
                        .stroke(accentCyan.opacity(0.4), lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(author.username)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("¿Qué quieres compartir?")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(accentCyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(accentCyan)
                    .font(.headline)
                
                Text("Contenido")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(description.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(primaryBlue.opacity(0.8))
                    )
            }
            
            TextEditor(text: $description)
                .foregroundColor(.white)
                .font(.body)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: 180)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(primaryBlue.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isTextEditorFocused ? accentCyan : Color.white.opacity(0.2), lineWidth: 1.5)
                        )
                )
                .focused($isTextEditorFocused)
                .animation(.easeInOut(duration: 0.2), value: isTextEditorFocused)
                .overlay(
                    // Placeholder personalizado
                    Group {
                        if description.isEmpty {
                            VStack {
                                HStack {
                                    Text("Describe tu proyecto, comparte tu conocimiento o pide ayuda a la comunidad...")
                                        .foregroundColor(.white.opacity(0.5))
                                        .font(.body)
                                        .padding(.leading, 20)
                                        .padding(.top, 24)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .allowsHitTesting(false)
                        }
                    }
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(accentCyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flag.fill")
                    .foregroundColor(accentCyan)
                    .font(.headline)
                
                Text("Tipo de Publicación")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // Selector de estado personalizado
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(PublicationStatus.allCases, id: \.self) { statusOption in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            status = statusOption
                        }
                    } label: {
                        HStack {
                            Image(systemName: iconForStatus(statusOption))
                                .font(.title3)
                            
                            Text(statusOption.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        .foregroundColor(status == statusOption ? darkBackground : .white.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(status == statusOption ? accentCyan : primaryBlue.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            status == statusOption ? Color.clear : accentCyan.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .scaleEffect(status == statusOption ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: status)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(accentCyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Botón para cargar borrador
            Button {
                showingDrafts = true
            } label: {
                HStack {
                    Image(systemName: "tray.and.arrow.down.fill")
                        .font(.title3)
                    Text("Cargar Borrador")
                        .font(.headline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(primaryBlue.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(accentCyan.opacity(0.4), lineWidth: 1)
                        )
                )
            }
            .disabled(isPosting)
            
            // Botón para guardar borrador
            Button {
                saveDraft()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.title3)
                    Text("Guardar Borrador")
                        .font(.headline)
                        .fontWeight(.medium)
                }
                .foregroundColor(description.isEmpty ? .gray : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(description.isEmpty ? Color.gray.opacity(0.3) : secondaryBlue.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(description.isEmpty ? Color.clear : accentCyan.opacity(0.4), lineWidth: 1)
                        )
                )
            }
            .disabled(description.isEmpty || isPosting)
        }
    }
    
    private func iconForStatus(_ status: PublicationStatus) -> String {
        switch status {
        case .help:
            return "questionmark.circle.fill"
        case .solved:
            return "checkmark.circle.fill"
        case .sharing:
            return "square.and.arrow.up.fill"
        @unknown default:
            return "circle.fill"
        }
    }
    
    private func saveDraft() {
        print("DEBUG: Botón 'Guardar Borrador' presionado para el autor: \(author.id)")
        
        let newDraft = PublicationDraft(
            description: description,
            status: status,
            authorUid: author.id
        )
        
        modelContext.insert(newDraft)
        
        do {
            try modelContext.save()
            print("DEBUG: ¡Guardado exitoso del borrador!")
        } catch {
            print("DEBUG: Error al guardar borrador: \(error.localizedDescription)")
        }
        
        dismiss()
    }
    
    private func createPublication() async {
        isPosting = true
        do {
            try await publicationService.createPublication(
                description: description,
                status: status,
                imageData: nil,
                author: author
            )
            dismiss()
        } catch {
            print("Error al crear la publicación: \(error.localizedDescription)")
            isPosting = false
        }
    }
}
