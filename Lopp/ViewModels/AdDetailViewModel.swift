// Filnavn: AdDetailViewModel.swift
import Foundation
import Combine
import Supabase

@MainActor
class AdDetailViewModel: ObservableObject {
    // Korrekt: Hver variabel på sin egen linje
    @Published var isLoading = false
    @Published var newChatId: UUID?
    @Published var deleteError: String?
    // NYTT: Status for rapportering
    @Published var reportSuccess: Bool = false
    @Published var reportError: String?

    func startChat(for ad: Ad) {
        isLoading = true
        Task {
            do {
                newChatId = try await ChatRepository.startChat(for: ad)
                print("Chat started: \(newChatId!)")
            } catch {
                print("Chat start error: \(error.localizedDescription)") // Mer informativ feilmelding
            }
            isLoading = false
        }
    }
    
    // NY FUNKSJON: Rapporterer annonsen
    func reportAd(ad: Ad, reason: String) async {
        guard let adId = ad.id else {
            reportError = "Annonse-ID mangler."
            return
        }
        
        isLoading = true
        reportError = nil
        reportSuccess = false
        
        defer { isLoading = false }
        
        do {
            try await AdsRepository.reportAd(adId: adId, reason: reason)
            reportSuccess = true
        } catch {
            reportError = error.localizedDescription
            print("Feil ved rapportering: \(error.localizedDescription)")
        }
    }
    
    // Håndterer sletting av annonsen
    func deleteAd(ad: Ad) async -> Bool {
        isLoading = true
        deleteError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            try await AdsRepository.deleteAd(ad: ad)
            return true
        } catch {
            deleteError = error.localizedDescription
            print("Feil ved sletting av annonse: \(error.localizedDescription)")
            return false
        }
    }
}
