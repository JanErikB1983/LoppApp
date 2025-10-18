// Filnavn: supabaseClient+APP.swift
import Foundation
import Supabase

// Pass på at disse stemmer med ditt Supabase-prosjekt!
enum AppSecrets {
    static let url = URL(string: "https://yxnlncjetsjwwwtvimxm.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4bmxuY2pldHNqd3d3dHZpbXhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1MTcyNzksImV4cCI6MjA3NjA5MzI3OX0.9QOOjfA62q00MplZyoRaBDGK3CHCeRLmYGTS-9m3lmc"
}

let supabase = SupabaseClient(supabaseURL: AppSecrets.url, supabaseKey: AppSecrets.anonKey)
