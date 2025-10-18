// Filnavn: NewAdView.swift
import SwiftUI

struct NewAdView: View {
    @Binding var selection: AdType?

    var body: some View {
        VStack(spacing: 20) {
            Text("Velg annonsetype")
                .font(.title2).bold()
            
            ForEach(AdType.allCases) { type in
                Button { selection = type } label: {
                    Text(type.displayName)
                        .font(.title3).bold() // Større og fetere tekst
                        .frame(maxWidth: .infinity).padding()
                        
                        // Bruker bakgrunnsfarge fra designsystemet (Dyp grå)
                        .background(Color.appCardBackground)
                        
                        // Fargelegger teksten mykt
                        .foregroundColor(Color.appTextPrimary)
                        
                        .cornerRadius(12)
                        
                        // NYTT: Subtil, men tydelig markering av valgt knapp
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selection == type ? Color.appPrimary : Color.clear, lineWidth: 3)
                        )
                }
            }
            Spacer()
        }
        .padding()
    }
}
