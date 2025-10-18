// Filnavn: MessagesViewModel.swift
import Foundation
import Combine

@MainActor
class MessagesViewModel: ObservableObject {
    
    // Bruker den nye ChatPreview-modellen
    @Published var chatPreviews: [ChatPreview] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchChats() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Kaller den korrekte funksjonen
                self.chatPreviews = try await ChatRepository.fetchChatPreviews()
            } catch {
                self.errorMessage = error.localizedDescription
                print("Feil ved henting av chat previews: \(error)")
            }
            isLoading = false
        }
    }
}
