//
//  DraftsListView.swift
//  CodeLink
//
//  Created by Jamil Turpo on 27/06/25.
//

import SwiftUI
import SwiftData

struct DraftsListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var drafts: [PublicationDraft] = []
    
    let currentUserId: String
    var onSelectDraft: (PublicationDraft) -> Void
    
    // MARK: - Color Palette
    private let primaryBlue = Color(red: 0.1, green: 0.2, blue: 0.4)
    private let secondaryBlue = Color(red: 0.2, green: 0.4, blue: 0.7)
    private let accentCyan = Color(red: 0.4, green: 0.8, blue: 1.0)
    private let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.1)
    private let cardBackground = Color(red: 0.15, green: 0.25, blue: 0.4)
    
    var body: some View {
        NavigationStack {
            ZStack {
                darkBackground.ignoresSafeArea()
                
                Group {
                    if drafts.isEmpty {
                        emptyStateView
                    } else {
                        draftsListView
                    }
                }
            }
            .navigationTitle("Borradores")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(darkBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundStyle(accentCyan)
                    .fontWeight(.semibold)
                }
            }
            .onAppear(perform: fetchDrafts)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(primaryBlue.opacity(0.4))
                    .frame(width: 120, height: 120)
                Image(systemName: "pencil.and.scribble")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(accentCyan)
            }
            
            VStack(spacing: 8) {
                Text("No tienes borradores guardados")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text("Tus borradores aparecerán aquí cuando los crees")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
    
    private var draftsListView: some View {
        List {
            ForEach(drafts) { draft in
                DraftCard(
                    draft: draft,
                    primaryBlue: primaryBlue,
                    secondaryBlue: secondaryBlue,
                    accentCyan: accentCyan,
                    cardBackground: cardBackground,
                    onTap: {
                        onSelectDraft(draft)
                        dismiss()
                    }
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .onDelete(perform: deleteDraft)
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .refreshable {
            fetchDrafts()
        }
    }
    
    private func fetchDrafts() {
        print("DEBUG: .onAppear activado. Buscando borradores para el usuario: \(currentUserId)")
        
        let predicate = #Predicate<PublicationDraft> { draft in
            draft.authorUid == currentUserId
        }
        let sort = SortDescriptor(\PublicationDraft.createdAt, order: .reverse)
        let descriptor = FetchDescriptor<PublicationDraft>(predicate: predicate, sortBy: [sort])
        
        do {
            let fetchedDrafts = try modelContext.fetch(descriptor)
            print("DEBUG: ¡Éxito! Se encontraron \(fetchedDrafts.count) borradores.")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.drafts = fetchedDrafts
            }
        } catch {
            print("DEBUG: ERROR al cargar los borradores: \(error.localizedDescription)")
        }
    }
    
    private func deleteDraft(at offsets: IndexSet) {
        for index in offsets {
            let draftToDelete = drafts[index]
            modelContext.delete(draftToDelete)
            
            do {
                try modelContext.save()
            } catch {
                print("DEBUG: Error al guardar después de eliminar: \(error.localizedDescription)")
            }
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            drafts.remove(atOffsets: offsets)
        }
    }
}

struct DraftCard: View {
    let draft: PublicationDraft
    let primaryBlue: Color
    let secondaryBlue: Color
    let accentCyan: Color
    let cardBackground: Color
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(primaryBlue.opacity(0.8))
                        .frame(width: 50, height: 50)
                    Image(systemName: "doc.text")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(accentCyan)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(draft.draftDescription)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundStyle(accentCyan)
                        
                        Text("Guardado: \(draft.createdAt, format: .relative(presentation: .named))")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accentCyan.opacity(0.6))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(accentCyan.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0) { } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

