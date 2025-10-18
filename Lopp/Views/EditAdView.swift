// Filnavn: EditAdView.swift
import SwiftUI
import PhotosUI

struct EditAdView: View {
    @StateObject private var viewModel: EditAdViewModel
    var onSaveComplete: () -> Void
    @Environment(\.dismiss) private var dismiss

    init(ad: Ad, onSaveComplete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EditAdViewModel(ad: ad))
        self.onSaveComplete = onSaveComplete
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Detaljer") {
                    TextField("Tittel", text: $viewModel.title)
                    TextEditor(text: $viewModel.description).frame(minHeight: 120)
                }

                Section(header: Text(sectionHeaderForAdType())) { // Kaller hjelpefunksjon
                    if viewModel.ad.type == "swap" { TextField("Ønsker i bytte", text: $viewModel.wantText) }
                    else if viewModel.ad.type == "want" { TextField("Jeg ønsker", text: $viewModel.wantText); TextField("Kan tilby (valgfritt)", text: $viewModel.offerText) }
                    else if viewModel.ad.type == "service" { TextField("Veiledende pris (kr)", text: $viewModel.price).keyboardType(.numberPad) }
                }

                Section("Bilder (\(viewModel.existingImageURLs.count + viewModel.newImages.count)/5)") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.existingImageURLs, id: \.self) { url in AsyncImage(url: url) { i in i.resizable().scaledToFill() } placeholder: { ProgressView() }.frame(width: 80, height: 80).cornerRadius(8).overlay(alignment: .topTrailing) { Button { viewModel.markImageForDeletion(url: url) } label: { Image(systemName: "xmark.circle.fill").foregroundColor(.red).background(Circle().fill(.white)) }.offset(x: 8, y: -8) } }
                            ForEach(viewModel.newImages, id: \.self) { img in Image(uiImage: img).resizable().scaledToFill().frame(width: 80, height: 80).cornerRadius(8).overlay(alignment: .topTrailing) { Button { viewModel.removeNewImage(img) } label: { Image(systemName: "xmark.circle.fill").foregroundColor(.red).background(Circle().fill(.white)) }.offset(x: 8, y: -8) } }
                        }
                    }.frame(height: 90)
                    
                    if viewModel.existingImageURLs.count + viewModel.newImages.count < 5 {
                        PhotosPicker(selection: $viewModel.pickerItems, maxSelectionCount: 5 - (viewModel.existingImageURLs.count + viewModel.newImages.count), matching: .images) { Label("Legg til bilder", systemImage: "photo.on.rectangle.angled") }
                    } else { Text("Maks antall bilder (5) er nådd.").font(.caption).foregroundColor(.secondary) }
                }

                if let msg = viewModel.errorMessage { Section { Text("Feil: \(msg)").foregroundColor(.red) } }
            }
            .navigationTitle("Rediger annonse").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Avbryt") { dismiss() }
                        // NYTT: Bruker Secondary stil for "Avbryt"
                        .buttonStyle(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Lagre") { Task { let success = await viewModel.saveChanges(); if success { onSaveComplete(); dismiss() } } }
                    // Bruker den allerede definerte Primary stilen
                    .buttonStyle(.primary)
                    .disabled(viewModel.isLoading || !isDataValid())
                }
            }
            .overlay { if viewModel.isLoading { Color.black.opacity(0.4).ignoresSafeArea(); ProgressView("Lagrer...").tint(.white).foregroundColor(.white) } }
        }
    }

    // --- HJELPEFUNKSJONENE DEFINERT KUN ÉN GANG ---
    private func sectionHeaderForAdType() -> String {
        switch viewModel.ad.type { case "swap": "Byttedetaljer"; case "want": "Ønskedetaljer"; case "service": "Tjenestedetaljer"; default: "Detaljer" }
    }
    
    private func isDataValid() -> Bool {
        return viewModel.title.count >= 5 && viewModel.description.count >= 20 && (viewModel.existingImageURLs.count + viewModel.newImages.count >= 1) && (viewModel.ad.type != "swap" || viewModel.wantText.count >= 5)
    }
}
