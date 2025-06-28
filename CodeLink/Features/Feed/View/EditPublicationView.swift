import SwiftUI

struct EditPublicationView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var publication: Publication

    private let publicationService = PublicationService()
    @State private var isSaving = false
    @State private var showContent = false // Para animaciones de entrada/salida

    // Paleta de colores
    private let primaryDark = Color(red: 0.05, green: 0.08, blue: 0.15)
    private let secondaryDark = Color(red: 0.08, green: 0.12, blue: 0.20)
    private let accentBlue = Color(red: 0.20, green: 0.50, blue: 0.85)
    private let lightBlue = Color(red: 0.40, green: 0.70, blue: 0.95)
    private let pureBlack = Color(red: 0.02, green: 0.02, blue: 0.05)
    private let softWhite = Color.white.opacity(0.95)
    private let glassMorphism = Color.white.opacity(0.08)

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [pureBlack, primaryDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if showContent {
                    VStack(spacing: 0) {
                        headerSection
                            .transition(.move(edge: .top).combined(with: .opacity))

                        ScrollView {
                            VStack(spacing: 28) {
                                descriptionSection
                                    .transition(.scale.combined(with: .opacity))
                                statusSection
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                            .padding(.bottom, 120)
                        }

                        floatingActionButton
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.85), value: showContent)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showContent = true
                }
            }
            .onDisappear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showContent = false
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Editar Publicación")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(softWhite)

                    Text("Modifica los detalles de tu contenido")
                        .font(.caption)
                        .foregroundColor(lightBlue.opacity(0.7))
                }

                Spacer()

                Button(action: {
                    withAnimation {
                        dismiss()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(lightBlue)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(glassMorphism)
                                .overlay(
                                    Circle()
                                        .stroke(lightBlue.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    secondaryDark.opacity(0.8)
                    LinearGradient(
                        colors: [glassMorphism, Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )

            HStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, lightBlue, accentBlue, Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
            }
            .padding(.horizontal, 60)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(lightBlue)
                    .frame(width: 20)

                Text("Descripción")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(softWhite)

                Spacer()
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(secondaryDark.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [lightBlue.opacity(0.3), accentBlue.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: pureBlack.opacity(0.3), radius: 10, x: 0, y: 5)

                if publication.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Escribe una descripción detallada...")
                        .foregroundColor(softWhite.opacity(0.4))
                        .font(.system(size: 16))
                        .padding(20)
                }

                TextEditor(text: $publication.description)
                    .padding(18)
                    .foregroundColor(softWhite)
                    .font(.system(size: 16, weight: .regular))
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: 160)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(secondaryDark.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(lightBlue.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: pureBlack.opacity(0.2), radius: 15, x: 0, y: 8)
        )
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "flag.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(lightBlue)
                    .frame(width: 20)

                Text("Estado de la Publicación")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(softWhite)

                Spacer()
            }

            Menu {
                ForEach(PublicationStatus.allCases, id: \.self) { status in
                    Button(action: {
                        publication.status = status
                    }) {
                        HStack {
                            Text(status.displayName)
                            if publication.status == status {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(publication.status.displayName)
                        .foregroundColor(softWhite)
                        .font(.system(size: 16, weight: .medium))

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(lightBlue)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(secondaryDark.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(lightBlue.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(secondaryDark.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(lightBlue.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: pureBlack.opacity(0.2), radius: 15, x: 0, y: 8)
        )
    }

    private var floatingActionButton: some View {
        HStack {
            Spacer()

            Button(action: {
                Task { await saveChanges() }
            }) {
                HStack(spacing: 12) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: softWhite))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                    }

                    Text(isSaving ? "Guardando..." : "Guardar Cambios")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(softWhite)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [lightBlue, accentBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [softWhite.opacity(0.3), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: lightBlue.opacity(0.4), radius: 15, x: 0, y: 8)
                        .shadow(color: pureBlack.opacity(0.3), radius: 5, x: 0, y: 2)
                )
            }
            .disabled(isSaving)
            .scaleEffect(isSaving ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSaving)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 34)
    }

    private func saveChanges() async {
        guard !isSaving else { return }

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        isSaving = true

        do {
            try await publicationService.updatePublication(publication)
            try await Task.sleep(nanoseconds: 500_000_000)

            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)

            withAnimation {
                dismiss()
            }
        } catch {
            print("Error al guardar: \(error.localizedDescription)")
            let errorFeedback = UINotificationFeedbackGenerator()
            errorFeedback.notificationOccurred(.error)
            isSaving = false
        }
    }
}
