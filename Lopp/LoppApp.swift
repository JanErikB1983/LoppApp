// Filnavn: LoppApp.swift
import SwiftUI

@main
struct LoppApp: App {
    // 1. Oppretter AuthViewModel slik at den lever under hele appens livssyklus
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            // 2. Starter appen med RootView, som håndterer logikk for innlogging/hovedside
            RootView()
                // 3. Gjør AuthViewModel tilgjengelig for RootView og alle underliggende views
                .environmentObject(authViewModel)
        }
    }
}
