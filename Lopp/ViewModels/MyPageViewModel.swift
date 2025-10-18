// Filnavn: MyPageViewModel.swift
import Foundation
import Combine
import Supabase

@MainActor
class MyPageViewModel: ObservableObject {
    // Korrekt: Hver variabel på sin egen linje
    @Published var myAds: [Ad] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // NY: ProfileViewModel blir initiert i loadData
    @Published var profileVM: ProfileViewModel?

    func fetchMyAds() {
        // ... (kode uendret) ...
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                myAds = try await AdsRepository.fetchMyAds()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    // NY: Håndterer både annonser og profil
    func loadData(userId: UUID) { // Krever nå userId
        // Sjekker om profileVM allerede er initialisert med korrekt ID
        if profileVM == nil {
            profileVM = ProfileViewModel(userId: userId)
        }
        
        fetchMyAds()
        profileVM?.fetchProfile()
    }
}
