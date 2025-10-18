// Filnavn: Lopp/Lopp/ViewModels/AuthViewModel.swift
import Foundation; import Supabase; import Combine

@MainActor class AuthViewModel: ObservableObject {
    @Published var user: User?
    // NYTT: Sjekker og lagrer samtykkestatus.
    @Published var hasAgreedToPrivacy: Bool = UserDefaults.standard.bool(forKey: "hasAgreedToPrivacy")
    
    private var t: Task<Void,Never>? = nil
    
    init() {
        t = Task {
            do {
                user = try await supabase.auth.session.user
            } catch {
                print(error)
            };
            for await (_, s) in supabase.auth.authStateChanges {
                user = s?.user
            }
        }
    }
    
    // NY FUNKSJON: Lagrer samtykke og oppdaterer Published-variabelen.
    func setPrivacyAgreement(agreed: Bool) {
        UserDefaults.standard.set(agreed, forKey: "hasAgreedToPrivacy")
        hasAgreedToPrivacy = agreed
    }
    
    func signUp(email: String, password: String, firstName: String) async throws {
        // 1. Registrer bruker i Supabase Auth
        _ = try await supabase.auth.signUp(email: email, password: password)
        
        // 2. Logg inn umiddelbart (Supabase krever ofte dette, med mindre e-postbekreftelse er på)
        _ = try await supabase.auth.signIn(email: email, password: password)
        
        // 3. Opprett profil med fornavn
        try await ProfileService.ensureProfile(firstName: firstName)
    }
    
    func signOut() { Task { try? await supabase.auth.signOut() } }
    
    deinit { t?.cancel() }
}
