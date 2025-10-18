// Filnavn: NewAdDetailsView.swift
import SwiftUI

struct NewAdDetailsView: View {
    @Binding var title: String
    @Binding var description: String
    var onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tittel").font(.headline)
            TextField("Skriv en kort tittel (5–80 tegn)", text: $title).textFieldStyle(.roundedBorder)
            Text("Beskrivelse").font(.headline)
            TextEditor(text: $description).frame(minHeight: 120).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
            Spacer()
            Button("Neste ➜", action: onNext).buttonStyle(.borderedProminent).disabled(title.count < 5 || description.count < 20)
        }
        .padding()
    }
}
