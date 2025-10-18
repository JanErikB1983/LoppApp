// Filnavn: DesignSystem.swift
import SwiftUI

// MARK: - Farger
extension Color {
    // BRUKER NØYAKTIG LOGOFARGE: fc5e1d
    static let appPrimary = Color(hex: "#fc5e1d")
    static let appPrimaryDark = Color(hex: "#d14b14") // Justert mørkere
    static let appPrimaryLight = Color(hex: "#fff3ee") // Lys aksent
    
    // Sekundærfarge og tilbakemeldinger (mindre endret, men ryddigere)
    static let appSecondary = Color(hex: "#0f766e")
    static let appAccentInfo = Color(hex: "#2563eb")
    static let appSuccess = Color(hex: "#16a34a")
    static let appWarning = Color(hex: "#f59e0b")
    static let appError = Color(hex: "#dc2626")
    
    // MODERNE MØRKE TEMA GRÅTONER (Med bedre dybde og mykere hvit)
    static let appBackground = Color(hex: "#0c0c0c") // Veldig mørk base
    static let appSurface = Color(hex: "#161618")    // Dybde 1 (Lett synlig fra bakgrunn)
    static let appCardBackground = Color(hex: "#242426") // Dybde 2 (Kort/grupper)
    
    // Mykere tekst for bedre lesbarhet i mørkt tema
    static let appTextPrimary = Color(hex: "#f0f0f5") // Ikke ren hvit (Moderne)
    static let appTextSecondary = Color(hex: "#c0c0c7")
    static let appTextMuted = Color(hex: "#8e8e93")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Komponenter
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            // Bruker den sterke primærfargen
            .background(Color.appPrimary)
            .foregroundColor(Color.white)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// NY STIL: For sekundære handlinger (som "Avbryt" i Modaler)
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            // Liten kant i sekundærfarge (lysere grå)
            .background(Color.appSurface)
            .foregroundColor(Color.appTextPrimary)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { .init() }
}

// NY EXTENSION: Tilgjengeliggjør SecondaryButtonStyle
extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { .init() }
}
