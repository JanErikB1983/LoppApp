// Filnavn: AdCardView.swift
import SwiftUI

struct AdCardView: View {
    let ad: Ad
    var distanceText: String?

    var body: some View {
        VStack(alignment: .leading) {
            // FIKS: Bruker CachedAsyncImageView med .fill for å få riktig aspektforhold
            CachedAsyncImageView(
                url: ad.imageURL,
                placeholder: Image(systemName: "photo").resizable(),
                contentMode: .fill // NY: Setter ContentMode til .fill
            )
            .frame(height: 150)
            .frame(maxWidth: .infinity) // Sikrer at den fyller bredden
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(ad.title).font(.headline).lineLimit(1)
                HStack {
                    Text(ad.city ?? "Ukjent sted").font(.subheadline).foregroundColor(.secondary)
                    Spacer()
                    
                    if let dist = distanceText {
                        Text(dist)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else if ad.photos.count > 1 {
                        Text("+\(ad.photos.count) bilder").font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}
