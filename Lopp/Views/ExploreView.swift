// Filnavn: ExploreView.swift
import SwiftUI

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Annonser nær \(viewModel.currentCity ?? "deg")").font(.footnote).foregroundColor(.secondary).padding(.top).padding(.bottom, 8)
                
                // KRITISK FIKS: Pakker Picker inn i Group for å tvinge accentColor på segmentkontrollen
                Group {
                    Picker("Filter", selection: $viewModel.selectedType) {
                        ForEach(ExploreViewModel.FilterType.allCases, id: \.self) { type in
                            Text(type.displayName)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    // Bruker den eldre men mer aggressive metoden for å tvinge farge i UIKit/SwiftUI
                    .accentColor(.appPrimary)
                    
                }
                .tint(.appPrimary) // Setter også moderne tint
                .padding(.horizontal)
                .padding(.bottom)
                
                ScrollView {
                    if viewModel.isLoading { ProgressView("Laster...").padding(.top, 50) }
                    else if let msg = viewModel.errorMessage { Text("Feil: \(msg)").foregroundColor(.red).padding() }
                    else if viewModel.filteredAndSortedAds.isEmpty {
                        Text("Ingen annonser funnet.").foregroundColor(.secondary).padding(.top, 50)
                    }
                    else {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredAndSortedAds) { ad in
                                NavigationLink(value: ad) {
                                    AdCardView(ad: ad)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .refreshable { viewModel.fetchAds() }
            }
            .navigationTitle("Utforsk").navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Ad.self) { ad in
                AdDetailView(ad: ad)
            }
            .task {
                if viewModel.ads.isEmpty {
                    viewModel.initializeLocationAndFetchAds()
                }
            }
        }
    }
}
