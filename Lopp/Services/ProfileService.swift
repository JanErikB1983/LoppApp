// Filnavn: ProfileService.swift
import Foundation
import Supabase

struct Profile: Codable {
    // Bruker den korrekte rekkefølgen og typen som matcher din database (antar Supabase Auth ID er UUID)
    let user_id: UUID
    var first_name: String
    var avatar_url: String?
    // Legger til Identifiable for bruk i SwiftUI om nødvendig
    var id: UUID { user_id }
}

enum ProfileService {
    
    // NY STRUCT for Update Payload
    private struct ProfileUpdatePayload: Encodable {
        let first_name: String
    }
    
    static func ensureProfile(firstName: String) async throws {
        // OBS: user.id er UUID
        let uid = try await supabase.auth.session.user.id
        let rows: [Profile] = try await supabase.from("profiles").select().eq("user_id", value: uid).limit(1).execute().value
        
        if rows.first == nil {
            let p = Profile(user_id: uid, first_name: firstName, avatar_url: nil)
            // Legger til .single() her for å matche Supabase best practice for INSERT
            _ = try await supabase.from("profiles").insert(p).select().single().execute()
        }
    }
    
    // NY FUNKSJON: Sletter brukeren permanent fra Supabase Auth og alle data
    static func deleteAccount() async throws {
        // KRITISK FIKS: Vi må slette brukeren gjennom en rpc-kall til en DB-funksjon.
        // Denne funksjonen MÅ du opprette i Supabase for å slette bruker fra auth.users,
        // da SDK-metoden feiler. Vi kaller den 'delete_current_user'.
        
        // Returnerer feil, men gir kompilerbar kode for å slette brukeren fra Auth.
        // Denne funksjonen er antatt å kalle delete_current_user() SQL-funksjonen
        // som deretter trigger sletting i Auth.users og CASCADE-slettingen.
        
        // VIKTIG: Hvis dette feiler, må du bytte tilbake til det enkle try await supabase.auth.signOut()
        // og legge til en lenke til Supabase Admin-panel for å slette Auth-posten der.
        
        // Fjerner Auth-spesifikt kall og bruker RPC for å overholde App Store-krav
        // (Forutsetter at du har opprettet SQL-funksjonen delete_current_user()).
        _ = try await supabase.rpc("delete_current_user").execute()
    }
    
    // Oppdater brukerprofilen
    static func updateProfile(firstName: String) async throws {
        let uid = try await supabase.auth.session.user.id
        let payload = ProfileUpdatePayload(first_name: firstName)
        
        _ = try await supabase
            .from("profiles")
            .update(payload)
            .eq("user_id", value: uid)
            .execute()
    }
    
    // Hent brukerprofilen
    static func fetchProfile(userId: UUID) async throws -> Profile {
        let profile: Profile = try await supabase
            .from("profiles")
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        return profile
    }
}
