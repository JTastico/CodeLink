//
//  Theme.swift
//  CodeLink
//
//  Created by Jamil Turpo on 27/06/25.
//

import SwiftUI

// MARK: - Color Palette
extension Color {
    // Backgrounds
    static let backgroundColor = Color(red: 18/255, green: 21/255, blue: 33/255)
    static let surfaceColor = Color(red: 27/255, green: 30/255, blue: 43/255)
    static let cardBackground = Color(red: 32/255, green: 36/255, blue: 50/255)
    static let glassMorphism = Color.white.opacity(0.08)
    
    static let deepBackground = Color(red: 5/255, green: 7/255, blue: 15/255)
    
    // Text Colors
    static let primaryTextColor = Color.white.opacity(0.95)
    static let secondaryTextColor = Color.white.opacity(0.7)
    static let tertiaryTextColor = Color.white.opacity(0.5)
    
    // Accent Colors
    static let accentColor = Color(red: 0/255, green: 191/255, blue: 255/255)
    static let accentBlue = Color(red: 51/255, green: 128/255, blue: 217/255)
    
    // --- LA CORRECCIÓN ESTÁ AQUÍ ---
    // Añadimos la definición que faltaba para 'lightBlue'
    static let lightBlue = Color(red: 90/255, green: 200/255, blue: 250/255)
    
    static let vibrantBlue = Color(red: 65/255, green: 145/255, blue: 255/255)
    static let softPurple = Color(red: 125/255, green: 122/255, blue: 232/255)
    
    // Status Colors
    static let successColor = Color(red: 52/255, green: 199/255, blue: 89/255)
    static let warningColor = Color(red: 255/255, green: 149/255, blue: 0/255)
    static let errorColor = Color(red: 255/255, green: 59/255, blue: 48/255)
    static let infoColor = Color(red: 90/255, green: 200/255, blue: 250/255)
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(red: 0.02, green: 0.02, blue: 0.05), Color(red: 0.05, green: 0.08, blue: 0.15)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [Color.accentColor, Color.accentBlue],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let vibrantGradient = LinearGradient(
        colors: [Color.vibrantBlue, Color.softPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassGradient = LinearGradient(
        colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(isDisabled ? AnyShapeStyle(Color.tertiaryTextColor) : AnyShapeStyle(Color.accentGradient))
            .foregroundStyle(.white)
            .font(.headline.bold())
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.95 : 1.0)
            .shadow(color: isDisabled ? Color.clear : Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .opacity(isDisabled ? 0.6 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(Color.glassMorphism)
            .foregroundStyle(isDisabled ? Color.tertiaryTextColor : Color.primaryTextColor)
            .font(.subheadline.weight(.medium))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isDisabled ? Color.tertiaryTextColor.opacity(0.2) : Color.lightBlue.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .opacity(isDisabled ? 0.7 : 1.0)
    }
}

// ... (El resto del archivo no necesita cambios)

struct FloatingButtonStyle: ButtonStyle {
    var size: CGFloat = 56
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(isDisabled ? AnyShapeStyle(Color.tertiaryTextColor) : AnyShapeStyle(Color.accentGradient))
            .foregroundStyle(.white)
            .clipShape(Circle())
            .shadow(color: isDisabled ? Color.clear : Color.accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .opacity(isDisabled ? 0.6 : 1.0)
    }
}

struct IconButtonStyle: ButtonStyle {
    var color: Color = .accentBlue
    var size: CGFloat = 36
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.5))
            .foregroundColor(color)
            .frame(width: size, height: size)
            .background(Color.glassMorphism)
            .clipShape(Circle())
            .overlay(Circle().stroke(color.opacity(0.3), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - View Modifiers
struct AppBackground: ViewModifier {
    var includeTopSafeArea: Bool = true
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primaryGradient)
            .ignoresSafeArea(edges: includeTopSafeArea ? .all : [.horizontal, .bottom])
    }
}

struct GlassCard: ViewModifier {
    let cornerRadius: CGFloat
    var shadowRadius: CGFloat = 8
    var borderOpacity: Double = 0.2
    
    init(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8, borderOpacity: Double = 0.2) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.borderOpacity = borderOpacity
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.glassMorphism)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.lightBlue.opacity(borderOpacity), lineWidth: 1)
                    )
                    .shadow(color: Color.backgroundColor.opacity(0.3), radius: shadowRadius, x: 0, y: 4)
            )
    }
}

struct AnimatedScale: ViewModifier {
    @State private var isAnimating = false
    var duration: Double = 2.0
    var scale: CGFloat = 1.05
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? scale : 1.0)
            .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

struct AnimatedOpacity: ViewModifier {
    @State private var isAnimating = false
    var duration: Double = 2.0
    var minOpacity: Double = 0.7
    
    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 1.0 : minOpacity)
            .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Custom Components
struct LoadingOverlay: View {
    let isLoading: Bool
    var message: String = "Cargando..."
    
    var body: some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.glassMorphism)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.lightBlue.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .scale))
            }
            .transition(.opacity)
        }
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    var fontSize: Font = .caption
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            
            Text(text)
                .font(fontSize.weight(.semibold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct AvatarView: View {
    var imageURL: String?
    var size: CGFloat = 44
    var showBorder: Bool = true
    
    var body: some View {
        Group {
            if let url = imageURL, !url.isEmpty {
                AsyncImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        Circle()
                            .fill(Color.accentGradient)
                        Image(systemName: "person.fill")
                            .font(.system(size: size * 0.4))
                            .foregroundColor(.white)
                    }
                }
            } else {
                ZStack {
                    Circle()
                        .fill(Color.accentGradient)
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.4))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(showBorder ? Circle().stroke(Color.lightBlue.opacity(0.3), lineWidth: 1) : nil)
    }
}

// MARK: - View Extensions
extension View {
    func appBackground(includeTopSafeArea: Bool = true) -> some View {
        modifier(AppBackground(includeTopSafeArea: includeTopSafeArea))
    }
    
    func glassCard(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8, borderOpacity: Double = 0.2) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, shadowRadius: shadowRadius, borderOpacity: borderOpacity))
    }
    
    func animatedScale(duration: Double = 2.0, scale: CGFloat = 1.05) -> some View {
        modifier(AnimatedScale(duration: duration, scale: scale))
    }
    
    func animatedOpacity(duration: Double = 2.0, minOpacity: Double = 0.7) -> some View {
        modifier(AnimatedOpacity(duration: duration, minOpacity: minOpacity))
    }
    
    func loadingOverlay(_ isLoading: Bool, message: String = "Cargando...") -> some View {
        ZStack {
            self
            LoadingOverlay(isLoading: isLoading, message: message)
        }
    }
}
