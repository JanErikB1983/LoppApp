//
//  CachedAsyncImageView.swift
//  Lopp
//
//  Created by Kode-mester.
//

import SwiftUI

struct CachedAsyncImageView: View {
    @StateObject private var loader: ImageLoader
    let placeholder: Image
    let contentMode: ContentMode // NY: For å kontrollere hvordan bildet skal skaleres
    
    // Vi må vite om URL-en er gyldig for å unngå lasting av "about:blank"
    private let isValidUrl: Bool
    
    init(url: URL?, placeholder: Image = Image(systemName: "photo"), contentMode: ContentMode = .fill) {
        // Håndterer nil URL ved å sende inn en dummy URL
        let finalUrl = url ?? URL(string: "about:blank")!
        
        self.isValidUrl = finalUrl.absoluteString != "about:blank"
        
        self._loader = StateObject(wrappedValue: ImageLoader(url: finalUrl))
        self.placeholder = placeholder
        self.contentMode = contentMode // Lagrer ContentMode
    }
    
    var body: some View {
        ZStack {
            if loader.isLoading {
                // Viser ProgressView som et overlay på placeholder
                placeholder.overlay(ProgressView()).foregroundColor(.secondary)
            } else if let image = loader.image {
                // FIKS: Bruker contentMode og aspectRatio for riktig skalering
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder.foregroundColor(.secondary)
            }
        }
        .onAppear {
            // Starter lasting kun hvis URLen er gyldig
            if isValidUrl {
                loader.load()
            }
        }
    }
}
