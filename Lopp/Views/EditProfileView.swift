// Filnavn: Lopp/Lopp/Views/EditProfileView.swift
//
//  EditProfileView.swift
//  Lopp
//
//  Created by Kode-mester.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var profileVM: ProfileViewModel // Må komme fra MyPageViewModel
    @State private var newFirstName: String
    @Environment(\.dismiss) var dismiss
    
    // NY: Binding for å signalisere til forelder (MyPageView) at oppdatering er fullført.
    @Binding var profileUpdated: Bool
    
    // Tar utgangspunkt i eksisterende navn
    init(profileVM: ProfileViewModel, profileUpdated: Binding<Bool>) {
        self.profileVM = profileVM
        self._newFirstName = State(initialValue: profileVM.profile?.first_name ?? "")
        self._profileUpdated = profileUpdated
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personlig informasjon")) {
                    TextField("Fornavn", text: $newFirstName)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                }
                
                if let msg = profileVM.errorMessage, !msg.isEmpty {
                    Section {
                        Text("Feil: \(msg)").foregroundColor(.red)
                    }
                }
                
                Button("Lagre endringer") {
                    Task {
                        let success = await profileVM.saveProfile(firstName: newFirstName)
                        if success {
                            // NY: Setter binding til true for å tvinge oppdatering i MyPageView
                            profileUpdated = true
                            dismiss()
                        }
                    }
                }
                .disabled(newFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || profileVM.isLoading)
            }
            .navigationTitle("Rediger Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Avbryt") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if profileVM.isLoading {
                        ProgressView()
                    }
                }
            }
        }
    }
}
