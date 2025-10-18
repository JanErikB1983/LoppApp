// Filnavn: NewAdLocationView.swift
import SwiftUI

struct NewAdLocationView: View {
    @ObservedObject var viewModel: CreateAdViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sted").font(.title2).bold()
            if viewModel.city == "Ukjent" && viewModel.viewState != .success && viewModel.viewState != .loading {
                ProgressView("Henter posisjon...")
            } else if viewModel.viewState != .success && viewModel.viewState != .loading {
                    Text("Annonsen vil bli vist nær **\(viewModel.city)**.").multilineTextAlignment(.center)
            }

            // Viser enten knapper eller status
            if viewModel.viewState == .idle || viewModel.viewState == .error("") {
                    Button("Bruk min posisjon") { viewModel.getLocation() }
                    Spacer()
                    Button("Publiser Annonse") { viewModel.publishAd() }
                        // NYTT: Bruker den nye primære stilen
                        .buttonStyle(.primary)
                        .disabled(viewModel.latitude == nil)
            } else {
                    Spacer() // Dytter status ned
                    statusView
                    Spacer() // Mer luft
            }
        }
        .padding()
        .onAppear { if viewModel.latitude == nil { viewModel.getLocation() } }
    }
    
    @ViewBuilder private var statusView: some View {
        switch viewModel.viewState {
        case .loading: ProgressView("Publiserer...")
        case .success: Text("✔️ Publisert!").font(.headline).foregroundColor(.green)
        case .error(let msg): VStack { Text("Feil: \(msg)").font(.footnote).foregroundColor(.red); Button("Prøv igjen") { viewModel.viewState = .idle }.buttonStyle(.bordered).padding(.top, 5) }
        default: EmptyView()
        }
    }
}
