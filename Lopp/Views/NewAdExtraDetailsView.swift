// Filnavn: NewAdExtraDetailsView.swift
import SwiftUI

struct NewAdExtraDetailsView: View {
    let adType: AdType
    @Binding var wantText: String
    @Binding var offerText: String // Er med, men vises kun for .want hvis nødvendig
    @Binding var price: String
    var onNext: () -> Void
    
    private var isNextButtonDisabled: Bool {
        switch adType {
        case .swap, .want:
            return wantText.count < 5
        case .service:
            return false // Ingen obligatoriske felt
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch adType {
            case .swap:
                Text("Hva ønsker du i bytte for det du tilbyr?").font(.headline)
                TextEditor(text: $wantText).frame(minHeight: 100).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
            
            case .want: // Fikset for å samle inn ønsket tekst og valgfritt tilbud
                Text("Hva ønsker du deg?").font(.headline)
                TextEditor(text: $wantText)
                    .frame(minHeight: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

                Text("Hva kan du tilby i bytte (Valgfritt)").font(.headline)
                TextEditor(text: $offerText)
                    .frame(minHeight: 50)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

            case .service:
                Text("Veiledende pris (Valgfritt)").font(.headline)
                TextField("F.eks. 250", text: $price).textFieldStyle(.roundedBorder).keyboardType(.numberPad)
            }
            
            Spacer()
            
            Button("Neste ➜", action: onNext)
                // NYTT: Bruker den nye primære stilen
                .buttonStyle(.primary)
                .disabled(isNextButtonDisabled)
        }
        .padding()
    }
}
