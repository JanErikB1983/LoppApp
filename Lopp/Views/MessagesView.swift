// Filnavn: MessagesView.swift
import SwiftUI

struct MessagesView: View {
    @StateObject private var viewModel = MessagesViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading { ProgressView("Laster...") }
                else if let msg = viewModel.errorMessage { Text("Feil: \(msg)").foregroundColor(.red).padding() }
                else if viewModel.chatPreviews.isEmpty { Text("Ingen aktive samtaler.").foregroundColor(.secondary).padding(.top, 50) }
                else {
                    List {
                        // --- OPPDATERT: Bruker chatPreviews ---
                        ForEach(viewModel.chatPreviews) { preview in
                            // --- OPPDATERT: Navigerer med preview.id ---
                            NavigationLink(value: preview.id) { // Sender kun ID
                                // --- OPPDATERT: Sender preview til raden ---
                                ChatRowView(preview: preview)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Meldinger")
            // --- OPPDATERT: Definerer destinasjon for UUID ---
            .navigationDestination(for: UUID.self) { chatId in
                ChatView(chatId: chatId) // Oppretter ChatView med ID
            }
            .onAppear {
                viewModel.fetchChats()
            }
        }
    }
}
