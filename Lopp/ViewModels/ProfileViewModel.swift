// Filnavn: ProfileViewModel.swift
import Foundation
import Combine
import Supabase

@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    // NYTT: Status for sletting
    @Published var deleteAccountError: String?
    
    private let userId: UUID
    
    init(userId: UUID) {
        self.userId = userId
    }
    
    // Henter profilinfo for innlogget bruker
    func fetchProfile() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                self.profile = try await ProfileService.fetchProfile(userId: self.userId)
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    // NY FUNKSJON: Kaller slettetjenesten
    func deleteAccount() async -> Bool {
        isLoading = true
        deleteAccountError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            try await ProfileService.deleteAccount()
            // AuthViewModel vil automatisk reagere på at brukeren er slettet og logge ut UI.
            return true
        } catch {
            deleteAccountError = error.localizedDescription
            print("Feil ved sletting av konto: \(error.localizedDescription)")
            return false
        }
    }
    
    // Lagrer endringer i profil
    func saveProfile(firstName: String) async -> Bool {
        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.errorMessage = "Navn kan ikke være tomt."
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await ProfileService.updateProfile(firstName: firstName)
            
            // Oppdaterer HELE profile-objektet for å GARANTERE en SwiftUI refresh
            if var currentProfile = profile {
                currentProfile.first_name = firstName
                self.profile = currentProfile
            }
            
            isLoading = false
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
