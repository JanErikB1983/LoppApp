//
//  AboutView.swift
//  Lopp
//
//  Created by Kode-mester.
//

import SwiftUI

struct AboutView: View {
    
    let contactEmail = "Lopp@gmail.com"
    
    var body: some View {
        Form {
            Section("Om Lopp - Byttetjenesten") {
                Text("Lopp er en tjeneste for bytte av varer og tjenester, utviklet med mål om å fremme gjenbruk og lokalt samarbeid.")
                    .foregroundColor(.appTextSecondary)
            }
            
            Section("Kontaktinformasjon (Ekomloven)") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Eier/Utvikler:").font(.headline)
                    Text("Lopp AS (Eksempelnavn)")
                    
                    Text("Kontakt oss:")
                        .font(.headline)
                        .padding(.top, 4)
                    
                    // Lenke for å starte e-post
                    Link(contactEmail, destination: URL(string: "mailto:\(contactEmail)")!)
                        .foregroundColor(.appPrimary)
                }
            }
            
            Section("Sletting av konto (GDPR)") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("I henhold til Personvernforordningen (GDPR) har du rett til å få slettet alle dine personopplysninger og kontoen din (Retten til sletting).")
                        .foregroundColor(.appTextSecondary)
                    
                    Text("Slik sletter du kontoen:")
                        .font(.headline)
                        .padding(.top, 4)
                    
                    // Tydelig instruksjon
                    Text("Send en e-post med emne 'Slett konto' til:")
                    Link(contactEmail, destination: URL(string: "mailto:\(contactEmail)?subject=Slett%20konto")!)
                        .foregroundColor(.appError) // Bruker error-farge for viktig handling
                }
            }
        }
        .navigationTitle("Om oss")
        .navigationBarTitleDisplayMode(.inline)
    }
}
