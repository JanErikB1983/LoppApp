//
//  SignUpView.swift
//  Lopp
//
//  Created by Kode-mester.
//

import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var statusMessage: String?
    @State private var isLoading = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Opprett konto")
                .font(.largeTitle).bold()
            
            TextField("Fornavn", text: $firstName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
            
            TextField("E-post", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)

            SecureField("Passord", text: $password)
                .textFieldStyle(.roundedBorder)

            Button {
                registerUser()
            } label: {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Registrer & Logg inn")
                }
            }
            .buttonStyle(.primary)
            .disabled(firstName.isEmpty || email.isEmpty || password.count < 6 || isLoading)

            if let msg = statusMessage {
                Text(msg)
                    .font(.footnote)
                    .foregroundColor(msg.contains("Feil") ? .appError : .appSuccess)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Registrering")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func registerUser() {
        isLoading = true
        statusMessage = nil
        Task {
            do {
                try await authViewModel.signUp(email: email, password: password, firstName: firstName)
                statusMessage = "Registrering fullført! Du er logget inn."
            } catch {
                statusMessage = "Feil: \(error.localizedDescription)"
                print("Sign up error: \(error)")
            }
            isLoading = false
        }
    }
}
