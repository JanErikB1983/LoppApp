//
//  ImageLoader.swift
//  Lopp
//
//  Created by Kode-mester.
//

import SwiftUI
import Combine

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: Image?
    @Published var isLoading = false
    
    public let url: URL
    private static let cache = URLCache.shared
    
    init(url: URL) {
        self.url = url
    }
    
    func load() {
        isLoading = true
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        
        // Sjekker først cachen
        if let cachedResponse = ImageLoader.cache.cachedResponse(for: request),
           let uiImage = UIImage(data: cachedResponse.data) {
            self.image = Image(uiImage: uiImage)
            self.isLoading = false
            return
        }

        // Hvis ikke i cache, last ned
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }

                if let uiImage = UIImage(data: data) {
                    // FIKS: Bruker korrekt metode for å lagre i cache
                    let cachedResponse = CachedURLResponse(response: response, data: data)
                    ImageLoader.cache.storeCachedResponse(cachedResponse, for: request)
                    
                    self.image = Image(uiImage: uiImage)
                } else {
                    // Prøver å unngå caching av dårlig data
                    ImageLoader.cache.removeCachedResponse(for: request)
                }
            } catch {
                print("Feil ved lasting av bilde: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}
