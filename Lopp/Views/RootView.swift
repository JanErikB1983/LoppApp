// Filnavn: RootView.swift
import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        // NY LOGIKK: Sjekker Samtykke -> Sjekker Auth
        if !authViewModel.hasAgreedToPrivacy {
            // 1. Vis Samtykkeside
            PrivacyConsentView()
        } else if authViewModel.user != nil {
            // 2. Vis Hovedapp hvis innlogget og samtykke er gitt
            TabBarView()
        } else {
            // 3. Vis Innloggingsside hvis samtykke er gitt, men ikke innlogget
            ContentView()
        }
    }
}
