// Filnavn: AboutView.swift
import SwiftUI

struct AboutView: View {

    let contactEmail = "Lopp@gmail.com"
    // Henter fargetema fra miljøet
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        // Form tilpasser seg vanligvis bra, men vi setter farger eksplisitt
        Form {
            Section("Om Lopp - Byttetjenesten") {
                Text("Lopp er en tjeneste for bytte av varer og tjenester, utviklet med mål om å fremme gjenbruk og lokalt samarbeid.")
                    // Bruker dynamisk farge
                    .foregroundColor(Color.dynamicTextSecondary(for: colorScheme))
            }
            // Gjør radene gjennomsiktige for å vise bakgrunnen
            .listRowBackground(Color.clear)

            Section("Kontaktinformasjon (Ekomloven)") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Eier/Utvikler:")
                        .font(.headline)
                        // Bruker dynamisk farge
                        .foregroundColor(Color.dynamicTextPrimary(for: colorScheme))
                    Text("Lopp AS (Eksempelnavn)")
                         // Bruker dynamisk farge
                        .foregroundColor(Color.dynamicTextSecondary(for: colorScheme))

                    Text("Kontakt oss:")
                        .font(.headline)
                        // Bruker dynamisk farge
                        .foregroundColor(Color.dynamicTextPrimary(for: colorScheme))
                        .padding(.top, 4)

                    // Lenke for å starte e-post
                    Link(contactEmail, destination: URL(string: "mailto:\(contactEmail)")!)
                         // Bruker dynamisk farge
                        .foregroundColor(Color.dynamicAppPrimary(for: colorScheme))
                }
            }
            .listRowBackground(Color.clear) // Gjør raden gjennomsiktig

            Section("Sletting av konto (GDPR)") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("I henhold til Personvernforordningen (GDPR) har du rett til å få slettet alle dine personopplysninger og kontoen din (Retten til sletting).")
                        // Bruker dynamisk farge
                        .foregroundColor(Color.dynamicTextSecondary(for: colorScheme))

                    Text("Slik sletter du kontoen:")
                        .font(.headline)
                        // Bruker dynamisk farge
                        .foregroundColor(Color.dynamicTextPrimary(for: colorScheme))
                        .padding(.top, 4)

                    // Tydelig instruksjon
                    Text("Send en e-post med emne 'Slett konto' til:")
                         // Bruker dynamisk farge
                        .foregroundColor(Color.dynamicTextSecondary(for: colorScheme))
                    Link(contactEmail, destination: URL(string: "mailto:\(contactEmail)?subject=Slett%20konto")!)
                         // Bruker dynamisk farge
                        .foregroundColor(Color.dynamicAppError(for: colorScheme)) // Bruker error-farge
                }
            }
            .listRowBackground(Color.clear) // Gjør raden gjennomsiktig
        }
        // Hjelper Form med riktig stil
        .environment(\.colorScheme, colorScheme)
        // Fjerner standard Form-bakgrunn
        .scrollContentBackground(.hidden)
        // Setter vår egen dynamiske bakgrunn
        .background(Color.dynamicBackgroundColor(for: colorScheme).ignoresSafeArea())
        .navigationTitle("Om oss")
        .navigationBarTitleDisplayMode(.inline)
         // Setter farge på toolbar/tittel
         .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
         // Setter tema for viewet (kan være redundant, men skader ikke)
         .preferredColorScheme(colorScheme == .dark ? .dark : .light)
    }
}
