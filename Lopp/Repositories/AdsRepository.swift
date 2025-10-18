// Filnavn: AdsRepository.swift
import Foundation
import Supabase

struct Ad: Codable, Identifiable, Hashable {
// ... (Struktur uendret) ...
    let id: UUID?
    var owner_id: UUID
    var type: String
    var title: String
    var description: String
    var photos: [String]
    var want_text: String?
    var latitude: Double?
    var longitude: Double?
    var city: String?
    var offer_text: String?
    var price_cents: Int?

    var imageURL: URL? {
        guard let firstPhotoPath = photos.first else { return nil }
        // OBS: Bruker globalt definert 'supabase'
        return try? supabase.storage.from("ads").getPublicURL(path: firstPhotoPath)
    }

    var imageURLs: [URL] {
        photos.compactMap { path in
            // OBS: Bruker globalt definert 'supabase'
            try? supabase.storage.from("ads").getPublicURL(path: path)
        }
    }
}

// Struct for oppdatering
private struct AdUpdatePayload: Encodable {
// ... (Struktur uendret) ...
    let title: String
    let description: String
    let photos: [String]
    let want_text: String?
    let offer_text: String?
    let price_cents: Int?
}

// NY STRUCT: For å fikse Encodaable-feilen i rapportering
private struct AdReportPayload: Encodable {
    let ad_id: UUID
    let reporter_id: UUID
    let reason: String
    
    // Må implementere CodingKeys for å mappe ad_id til target_ad i DB
    enum CodingKeys: String, CodingKey {
        case ad_id = "target_ad" // Mapper feltet i Swift til kolonnen i Supabase
        case reporter_id, reason
    }
}

// Hjelpefunksjon for å konvertere tomme strenger til nil
private extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        switch self {
        case .some(let s) where s.isEmpty: return nil
        default: return self
        }
    }
}


enum AdsRepository {

    // --- FUNKSJON FOR Å HENTE ÉN ANNONSE ---
    static func fetchAd(id: UUID) async throws -> Ad {
        let ad: Ad = try await supabase
            .from("ads")
            .select() // Henter alle kolonner
            .eq("id", value: id)
            .single()
            .execute()
            .value
        return ad
    }

    static func updateAd(
        adId: UUID,
        title: String,
        description: String,
        wantText: String?,
        offerText: String?,
        priceCents: Int?,
        imagePathsToDelete: [String],
        newImageData: [Data]
    ) async throws {
        
        // --- Bruker en MEST STABIL versjon av updateAd ---
        
        guard let userId = try? await supabase.auth.session.user.id else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Bruker er ikke logget inn."])
        }
        
        // 1. Hent den originale annonsen for å få de eksisterende bildene trygt
        let currentAd: Ad = try await AdsRepository.fetchAd(id: adId)

        // 2. Slett gamle bilder
        if !imagePathsToDelete.isEmpty {
            try await supabase.storage.from("ads").remove(paths: imagePathsToDelete)
        }

        // 3. Last opp nye bilder
        var newUploadedPaths: [String] = []
        if !newImageData.isEmpty {
            for imgData in newImageData {
                let name = UUID().uuidString + ".jpg"; let path = "\(userId.uuidString)/\(adId.uuidString)/\(name)"
                try await supabase.storage.from("ads").upload(path: path, file: imgData)
                newUploadedPaths.append(path)
            }
        }

        // 4. Bygg ny bildeliste: Fjern slettede, legg til nye.
        var updatedPhotoPaths = currentAd.photos
        updatedPhotoPaths.removeAll { imagePathsToDelete.contains($0) }
        updatedPhotoPaths.append(contentsOf: newUploadedPaths)

        // 5. Lag payload-objektet
        let payload = AdUpdatePayload(
            title: title,
            description: description,
            photos: updatedPhotoPaths,
            want_text: wantText.nilIfEmpty,
            offer_text: offerText.nilIfEmpty,
            price_cents: priceCents
        )

        // 6. Utfør databaseoppdateringen (uten select() for å unngå decodable-feil)
        _ = try await supabase
            .from("ads")
            .update(payload)
            .eq("id", value: adId)
            .execute() // Krever ingen returverdi.
    }
    
    // ... (resten av koden er uendret) ...

    // Sletter en annonse og dens tilhørende bilder
    static func deleteAd(ad: Ad) async throws {
        guard let adId = ad.id else {
            throw NSError(domain: "AdError", code: 101, userInfo: [NSLocalizedDescriptionKey: "Annonse-ID mangler."])
        }
        
        // 1. Slett alle bilder fra Supabase Storage (om de finnes)
        if !ad.photos.isEmpty {
            try await supabase.storage.from("ads").remove(paths: ad.photos)
        }
        
        // 2. Slett selve annonsen fra databasen
        _ = try await supabase
            .from("ads")
            .delete()
            .eq("id", value: adId)
            .execute()
        
        // OBS: Supabase Database-regler bør også slette relaterte chatter/meldinger (via CASCADE DELETE).
    }

    // Rapporterer en annonse
    static func reportAd(adId: UUID, reason: String) async throws {
        guard let reporterId = try? await supabase.auth.session.user.id else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Mangler innlogget bruker."])
        }
        
        // FIKS: Bruker AdReportPayload med UUID og CodingKeys
        let reportPayload = AdReportPayload(
            ad_id: adId,
            reporter_id: reporterId,
            reason: reason
        )
        
        // Dette skal nå mappe ad_id til target_ad i databasen
        _ = try await supabase.from("reports").insert(reportPayload).execute()
    }

    // --- Offentlige funksjoner ---
    static func fetchAds() async throws -> [Ad] { try await fetchAds_full(city: nil) }
    static func fetchMyAds() async throws -> [Ad] { try await fetchMyAds_full() }
    
    // FIKS: Gjeninnfører den offentlige createAd-funksjonen
    static func createAd(type: String, title: String, description: String, wantText: String, offerText: String, price: String, latitude: Double?, longitude: Double?, city: String?, photos: [Data]) async throws {
        try await createAd_full(type: type, title: title, description: description, wantText: wantText, offerText: offerText, price: price, latitude: latitude, longitude: longitude, city: city, photos: photos)
    }
    // ----------------------------

    private static func fetchAds_full(city: String?) async throws -> [Ad] {
        
        var baseQuery = supabase.from("ads").select()
        
        // Lokasjonsfiltrering er kommentert ut for å sikre at alle annonser vises.
        /*
        if let city = city, !city.isEmpty, city != "Ukjent" {
            baseQuery = baseQuery.eq("city", value: city)
        }
        */
        
        let ads: [Ad] = try await baseQuery
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return ads
    }
    
    private static func fetchMyAds_full() async throws -> [Ad] {
        let uid = try await supabase.auth.session.user.id
        // Henter alle annonser fra eieren.
        let ads: [Ad] = try await supabase.from("ads").select().eq("owner_id", value: uid).order("created_at", ascending: false).execute().value
        return ads
    }
    
    private static func createAd_full(type: String, title: String, description: String, wantText: String, offerText: String, price: String, latitude: Double?, longitude: Double?, city: String?, photos: [Data]) async throws {
        let user = try await supabase.auth.session.user
        let priceCents = Int(price).map { $0 * 100 }
        
        let ad = Ad(
            id: nil,
            owner_id: user.id,
            type: type,
            title: title,
            description: description,
            photos: [],
            want_text: wantText.isEmpty ? nil : wantText,
            latitude: latitude,
            longitude: longitude,
            city: city,
            offer_text: offerText.isEmpty ? nil : offerText,
            price_cents: priceCents
        )
        
        // 1. Sett inn annonsen
        let created: Ad = try await supabase.from("ads").insert(ad).select().single().execute().value
        
        // 2. Last opp bilder
        var paths: [String] = []
        guard let adId = created.id else { throw NSError(domain: "AdError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mangler annonse-ID etter opprettelse"]) }
        
        for imgData in photos {
            let name = UUID().uuidString + ".jpg";
            let path = "\(user.id.uuidString)/\(adId.uuidString)/\(name)"
            try await supabase.storage.from("ads").upload(path: path, file: imgData)
            paths.append(path)
        }
        
        // 3. Oppdater annonsen med bildestier
        _ = try await supabase.from("ads").update(["photos": paths]).eq("id", value: adId).execute()
    }
}
