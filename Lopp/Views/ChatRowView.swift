// Filnavn: ChatRowView.swift
import SwiftUI

struct ChatRowView: View {
    let preview: ChatPreview

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .clipShape(Circle())

            VStack(alignment: .leading) {
                // NY/FIKS: Setter sammen Annonsens tittel og Deltakerens navn/email.
                let adTitle = preview.ad_title ?? "Ukjent annonse"
                let participantInfo = preview.participant?.first_name ?? preview.participant?.email
                
                // Viser Annonsens tittel øverst (alltid meningsfull)
                Text(adTitle)
                    .font(.headline)
                    .lineLimit(1)
                
                // Sekundær linje: Viser hvem du snakker med (bedre enn "Ukjent deltaker")
                Text(participantInfo ?? "Startet samtale") // Fikser "Ukjent deltaker" til noe bedre
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                // Tredje linje: Siste melding
                Text(preview.last_message_body ?? "Ingen meldinger")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Viser når siste melding ble sendt
            VStack(alignment: .trailing) {
                Text(formattedDate(preview.last_message_at))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .frame(height: 50)
        }
        .padding(.vertical, 8)
    }

    // Hjelpefunksjon for å formatere dato
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(date) {
            return "I går"
        } else {
            return date.formatted(date: .numeric, time: .omitted)
        }
    }
}
