// Filnavn: AdDetailView.swift
import SwiftUI
import Supabase

struct AdDetailView: View {
    @State private var ad: Ad
    
    @StateObject private var viewModel = AdDetailViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowingEditView = false
    @State private var showingDeleteAlert = false
    @State private var showingReportSheet = false
    
    init(ad: Ad) {
        _ad = State(initialValue: ad)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                detailContent
                    .padding(.bottom, 8)
                
                // KRITISK FIKS: Sikrer at ScrollView har nok padding slik at
                // knapperaden i TabBar ikke overlappes i klikkområdet.
                .padding(.bottom, 80)

            }
            
            // Bruker dedikert komponent for knapper. FJERNER authViewModel fra parameterlisten her.
            AdDetailButtons(ad: ad, viewModel: viewModel,
                            showingDeleteAlert: $showingDeleteAlert, isShowingEditView: $isShowingEditView)
        }
        
        // ... (Toolbar og alerts uendret) ...
        .navigationTitle(ad.title).navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if authViewModel.user?.id != ad.owner_id {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingReportSheet = true
                    } label: {
                        Label("Rapporter", systemImage: "flag")
                    }
                }
            }
        }
        .navigationDestination(item: $viewModel.newChatId) { chatId in ChatView(chatId: chatId) }
        .sheet(
            isPresented: $isShowingEditView,
            onDismiss: {
                Task { await refreshAd() }
            }
        ) {
            EditAdView(ad: ad, onSaveComplete: {})
        }
        .sheet(isPresented: $showingReportSheet) {
            ReportAdSheet(viewModel: viewModel, ad: ad)
        }
        .alert("Slett annonse", isPresented: $showingDeleteAlert) {
            Button("Slett", role: .destructive) {
                Task {
                    let success = await viewModel.deleteAd(ad: ad)
                    if success {
                        dismiss()
                    }
                }
            }
            Button("Avbryt", role: .cancel) {}
        } message: {
            Text("Er du sikker på at du vil slette denne annonsen? Denne handlingen kan ikke angres.")
        }
        .alert("Feil", isPresented: .constant(viewModel.deleteError != nil), presenting: viewModel.deleteError) { _ in
            Button("OK") { viewModel.deleteError = nil }
        } message: { error in
            Text(error)
        }
        .alert("Takk", isPresented: $viewModel.reportSuccess) {
            Button("OK") {}
        } message: {
            Text("Annonsen er rapportert. Vi vil se gjennom innholdet.")
        }
    }
    
    @ViewBuilder
    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Bildekarusell
            TabView {
                if ad.imageURLs.isEmpty {
                    Color.gray.opacity(0.1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(Text("Ingen bilder."))
                }
                else {
                    ForEach(ad.imageURLs, id: \.self) { url in
                        CachedAsyncImageView(
                            url: url,
                            placeholder: Image(systemName: "photo"),
                            contentMode: .fill
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(height: 300)
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .ignoresSafeArea(.container, edges: .top)

            VStack(alignment: .leading, spacing: 8) {
                Text(ad.title).font(.largeTitle).fontWeight(.bold)
                Text(ad.city ?? "Ukjent sted").font(.callout).foregroundColor(.secondary)
            }.padding(.horizontal)
            
            Divider().padding(.horizontal)

            AdDetails(ad: ad)
            
            Divider().padding(.horizontal)
            Text(ad.description).padding(.horizontal)
        }
        .padding(.bottom)
    }
    
    // FUNKSJON for å hente annonsen på nytt
    private func refreshAd() async {
        guard let currentAdId = ad.id else { return }
        do {
            let updatedAd = try await AdsRepository.fetchAd(id: currentAdId)
            self.ad = updatedAd // Oppdaterer @State, som oppdaterer UI
        } catch {
            print("Kunne ikke oppdatere AdDetailView etter redigering: \(error)")
        }
    }
}

// NY KOMPONENT: Bryter ut DetailRowView-logikken
private struct AdDetails: View {
    let ad: Ad
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let wt = ad.want_text, !wt.isEmpty { DetailRowView(title: ad.type == "swap" ? "Ønsker i bytte" : "Jeg ønsker", value: wt) }
            if let ot = ad.offer_text, !ot.isEmpty { DetailRowView(title: "Kan tilby", value: ot) }
            if let pc = ad.price_cents { let kr = Double(pc)/100.0; DetailRowView(title: "Veiledende pris", value: String(format: "%.0f kr", kr)) }
        }
        .padding(.horizontal)
    }
}


// NY KOMPONENT: Bryter ut den komplekse knappelogikken
private struct AdDetailButtons: View {
    let ad: Ad
    @ObservedObject var viewModel: AdDetailViewModel
    
    // FIKS: Mottar AuthViewModel direkte fra miljøet
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Binding var showingDeleteAlert: Bool
    @Binding var isShowingEditView: Bool
    
    var body: some View {
        Group {
            if authViewModel.user?.id == ad.owner_id {
                HStack(spacing: 10) {
                    Button("Slett annonse") {
                        showingDeleteAlert = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.appError)
                    .padding(.horizontal, 15)
                    
                    Button("Rediger annonse") { isShowingEditView = true }
                        .buttonStyle(.primary)
                }
            } else {
                Button { viewModel.startChat(for: ad) } label: {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Start chat")
                    }
                }
                .buttonStyle(.primary)
                .disabled(viewModel.isLoading)
            }
        }
        .padding()
    }
}


// ... (Structs for DetailRowView og ReportAdSheet er uendret) ...

struct DetailRowView: View {
    let title: String, value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline).foregroundColor(.secondary)
            Text(value).font(.body)
        }
    }
}

// NY KOMPONENT: Sheet for Rapportering
struct ReportAdSheet: View {
    @ObservedObject var viewModel: AdDetailViewModel
    let ad: Ad
    @State private var reason: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Text("Vennligst beskriv hvorfor du rapporterer denne annonsen. Misbruk av rapporteringsfunksjonen kan føre til utestengelse.")
                    .font(.callout)
                    .foregroundColor(.appTextMuted)
                
                Section("Årsak") {
                    TextEditor(text: $reason)
                        .frame(minHeight: 100)
                }
                
                if let error = viewModel.reportError {
                    Text("Feil: \(error)").foregroundColor(.appError)
                }
            }
            .navigationTitle("Rapporter Annonse")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Avbryt") { dismiss() }
                        .buttonStyle(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Rapporter") {
                        Task {
                            await viewModel.reportAd(ad: ad, reason: reason)
                            if viewModel.reportSuccess {
                                dismiss()
                            }
                        }
                    }
                    .disabled(reason.count < 10 || viewModel.isLoading)
                }
            }
        }
    }
}
