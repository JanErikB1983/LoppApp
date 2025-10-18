// Filnavn: EditAdViewModel.swift
import Foundation
import Combine
import SwiftUI
import PhotosUI
import Supabase

@MainActor
class EditAdViewModel: ObservableObject {
    
    let ad: Ad
    
    @Published var title: String
    @Published var description: String
    @Published var wantText: String
    @Published var offerText: String
    @Published var price: String
    
    @Published var existingImageURLs: [URL] = []
    @Published var newImages: [UIImage] = []
    @Published var pickerItems: [PhotosPickerItem] = [] {
        didSet { Task { await loadNewImages() } }
    }
    private var imagePathsToDelete: [String] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(ad: Ad) {
        self.ad = ad
        self.title = ad.title
        self.description = ad.description
        self.wantText = ad.want_text ?? ""
        self.offerText = ad.offer_text ?? ""
        self.price = ad.price_cents.map { String($0 / 100) } ?? ""
        self.existingImageURLs = ad.imageURLs
    }
    
    private func loadNewImages() async {
        var loadedImages: [UIImage] = []; for item in pickerItems { if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) { loadedImages.append(img) } }; let currentTotal = existingImageURLs.count + newImages.count; let availableSlots = max(0, 5 - currentTotal); newImages.append(contentsOf: loadedImages.prefix(availableSlots)); pickerItems = []
    }

    func markImageForDeletion(url: URL) {
        // Bruker nå supabase.storage her
        if let pathToDelete = ad.photos.first(where: { path in url == (try? supabase.storage.from("ads").getPublicURL(path: path)) }) {
            imagePathsToDelete.append(pathToDelete)
            existingImageURLs.removeAll { $0 == url }
        } else {
            print("Fant ikke stien for URL: \(url)")
        }
    }

    func removeNewImage(_ image: UIImage) {
        newImages.removeAll { $0 == image }
    }

    func saveChanges() async -> Bool {
        guard let adId = ad.id else { errorMessage = "Mangler annonse-ID."; return false }
        guard !title.isEmpty, !description.isEmpty else { errorMessage = "Tittel/beskrivelse tom."; return false }
        guard existingImageURLs.count + newImages.count >= 1 else { errorMessage = "Minst ett bilde."; return false }

        isLoading = true; errorMessage = nil
        do {
            let newImageData = newImages.compactMap { ImageUtils.jpegDataScaled($0) }
            let priceCents = Int(price).map { $0 * 100 }
            
            // NY/FIKS: Kaller update uten å kreve returverdi, unngår Decoder-feilen.
            try await AdsRepository.updateAd(
                adId: adId, title: title, description: description,
                wantText: wantText.isEmpty ? nil : wantText,
                offerText: offerText.isEmpty ? nil : offerText,
                priceCents: priceCents,
                imagePathsToDelete: imagePathsToDelete,
                newImageData: newImageData
            )
            
            isLoading = false; return true
        } catch {
            errorMessage = error.localizedDescription; isLoading = false; return false
        }
    }
}
