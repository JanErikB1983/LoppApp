//
//  ChatDetailViewModel.swift
//  Lopp
//
//  Created by Kode-mester.
//

import Foundation
import Combine
import Supabase

@MainActor
class ChatDetailViewModel: ObservableObject {
    @Published var chatTitle: String = "Laster tittel..."
    @Published var participantName: String?
    @Published var isLoading = false
    
    private let chatId: UUID
    
    init(chatId: UUID) {
        self.chatId = chatId
    }
    
    func fetchDetails() {
        isLoading = true
        Task {
            do {
                let previews = try await ChatRepository.fetchChatPreviews()
                if let chat = previews.first(where: { $0.id == chatId }) {
                    
                    // FIKS: Bruker null-koalescing for å håndtere valgfrie strenger
                    chatTitle = chat.ad_title ?? "Ukjent annonse"
                    participantName = chat.participant?.first_name ?? nil
                    
                } else {
                    chatTitle = "Ukjent chat"
                }
            } catch {
                print("Feil ved henting av chat-detaljer: \(error.localizedDescription)")
                chatTitle = "Feil ved lasting"
            }
            isLoading = false
        }
    }
}
