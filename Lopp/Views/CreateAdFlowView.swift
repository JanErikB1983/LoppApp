// Filnavn: Lopp/Lopp/Views/CreateAdFlowView.swift
import SwiftUI

// FJERNER DUPLISERT DEFINISJON:
// enum AdType: String, CaseIterable, Identifiable { ... }

struct CreateAdFlowView: View {
    @StateObject private var viewModel = CreateAdViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            NewAdView(selection: $viewModel.adType) // Starten av flyten
                .navigationTitle("Ny annonse")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: CreateAdViewModel.Step.self) { step in
                    switch step {
                    case .details:
                        NewAdDetailsView(title: $viewModel.title, description: $viewModel.description) {
                            viewModel.proceedFromDetails()
                        }
                        .navigationTitle("Detaljer")
                    case .extraDetails:
                        NewAdExtraDetailsView(
                            // Må bruke AdType fra ExploreViewModel eller AdsRepository sin definisjon
                            adType: viewModel.adType ?? .swap,
                            wantText: $viewModel.wantText,
                            offerText: $viewModel.offerText,
                            price: $viewModel.price
                        ) {
                            viewModel.path.append(CreateAdViewModel.Step.photos)
                        }
                        .navigationTitle("Ekstra detaljer")
                    case .photos:
                        NewAdPhotosView(viewModel: viewModel)
                            .navigationTitle("Bilder")
                    case .location:
                        NewAdLocationView(viewModel: viewModel)
                            .navigationTitle("Sted")
                    }
                }
                .onChange(of: viewModel.adType) { _, newValue in
                    if newValue != nil, viewModel.path.isEmpty { // Gå kun videre hvis vi er på startskjermen
                        viewModel.path.append(CreateAdViewModel.Step.details)
                    }
                }
        }
        .onChange(of: viewModel.viewState) { _, newState in
            if newState == .success {
                Task {
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    dismiss()
                }
            }
        }
    }
}
