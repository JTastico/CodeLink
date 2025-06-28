//
//  Theme.swift
//  CodeLink
//
//  Created by Jamil Turpo on 27/06/25.
//

import SwiftUI

// Extendemos Color para añadir nuestros colores personalizados.
// Esto nos permite llamarlos fácilmente como Color.backgroundColor
extension Color {
    static let backgroundColor = Color(red: 18/255, green: 21/255, blue: 33/255) // Un azul muy oscuro
    static let surfaceColor = Color(red: 27/255, green: 30/255, blue: 43/255) // Un azul ligeramente más claro para las superficies
    static let primaryTextColor = Color.white.opacity(0.9)
    static let secondaryTextColor = Color.gray
    static let accentColor = Color(red: 0/255, green: 191/255, blue: 255/255) // Celeste/Cyan brillante
}

// Creamos un estilo de botón personalizado para los botones principales.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .font(.headline.bold())
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Creamos un modificador de vista para aplicar el fondo fácilmente.
struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundColor)
            .ignoresSafeArea()
    }
}
