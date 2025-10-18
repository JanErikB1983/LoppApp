// Filnavn: ContentView.swift
import SwiftUI
import Supabase

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var statusMessage: String?
    @State private var isLoading = false
    
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        // Navigasjonsstack for å støtte registrering som en push-destinasjon
        NavigationStack {
            VStack(spacing: 16) {
                Text("Velkommen til Lopp")
                    .font(.largeTitle).bold()
                    .padding(.bottom, 20)
                
                TextField("E-post", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)

                SecureField("Passord", text: $password)
                    .textFieldStyle(.roundedBorder)

                Button {
                    signInUser()
                } label: {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Logg inn")
                    }
                }
                .buttonStyle(.primary)
                .disabled(email.isEmpty || password.isEmpty || isLoading)
                
                if let msg = statusMessage {
                    Text(msg)
                        .font(.footnote)
                        .foregroundColor(.appError)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                // Lenke til Registrering
                NavigationLink("Har du ikke konto? Registrer deg her.") {
                    SignUpView()
                }
                .font(.subheadline)
                .padding(.top, 10)
            }
            .padding()
        }
    }
    
    private func signInUser() {
        isLoading = true
        statusMessage = nil
        Task {
            do {
                _ = try await supabase.auth.signIn(email: email, password: password)
            } catch {
                statusMessage = "Feil ved innlogging: \(error.localizedDescription)"
                print("Sign in error: \(error)")
            }
            isLoading = false
        }
    }
}
