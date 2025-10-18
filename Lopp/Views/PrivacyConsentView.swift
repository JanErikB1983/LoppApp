//
//  PrivacyConsentView.swift
//  Lopp
//
//  Created by Kode-mester.
//

import SwiftUI

// Mock-innhold for brukeravtale og personvern. Dette må fylles ut med din faktiske tekst.
private let longText = """
**1. Innsamling av data (GDPR):**
Vi samler inn dine personopplysninger for å levere tjenesten. Dette inkluderer din unike bruker-ID (fra Supabase Auth), ditt fornavn, e-postadresse og frivillig oppgitt lokasjonsdata (by, bredde/lengdegrad) for annonsering og sortering. Disse dataene er nødvendige for å utføre tjenesten (bytte/søke ting).

**2. Formål og samtykke (GDPR/ekomloven):**
Ved å fortsette gir du ditt eksplisitte samtykke til at vi kan lagre og behandle dine personopplysninger som beskrevet ovenfor. Du samtykker spesifikt til at vi kan lagre lokasjonsdata for å filtrere annonser i ditt område. Du kan når som helst trekke tilbake dette samtykket ved å slette kontoen din.

**3. Informasjonskapsler (Cookies/Lokallagring):**
Vi bruker ikke tradisjonelle informasjonskapsler, men lagrer tekniske data (som innloggingsstatus og ditt samtykke til denne avtalen) lokalt på din enhet (UserDefaults) for å sikre funksjonalitet.

**4. Datalagring og Sikkerhet:**
Alle data lagres sikkert hos vår databehandler, Supabase (Postgres/Storage). Vi lagrer ikke passord; dette håndteres av Supabase.

**5. Dine Rettigheter:**
Du har rett til innsyn, retting og sletting av dine data i henhold til GDPR.
"""

struct PrivacyConsentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Personvern og Brukeravtale")
                .font(.title).bold()
                .padding(.bottom)
            
            // Visning av avtaleteksten
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text(longText)
                        .font(.body)
                        .foregroundColor(.appTextSecondary)
                }
                .padding()
            }
            // Bakgrunn som matcher kortene
            .background(Color.appCardBackground)
            .cornerRadius(12)
            .padding()

            // Samtykkeknapp
            Button("Jeg godtar vilkårene og fortsetter") {
                authViewModel.setPrivacyAgreement(agreed: true)
            }
            .buttonStyle(.primary)
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}
