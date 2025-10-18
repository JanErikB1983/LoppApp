// Filnavn: ChatRepository.swift
import Foundation
import Supabase

// --- NY/OPPDATERT: Sub-struktur for motparten ---
struct ChatParticipant: Codable, Hashable {
    let id: UUID // Den andre personens UUID
    var first_name: String?
    let avatar_url: String?
    var email: String? // NYTT: E-post som fallback
}

// --- OPPDATERT DEFINISJON FOR ChatPreview ---
struct ChatPreview: Codable, Identifiable, Hashable {
    let id: UUID // Chat ID
    let ad_id: UUID
    var ad_title: String?
    var expires_at: Date?
    
    // NYTT: Informasjon om den andre deltakeren
    var participant: ChatParticipant?
    
    // NYTT: Siste melding
    let last_message_body: String?
    let last_message_at: Date?
    
    // NYTT: Hjelpe-property for å finne ut om meldingen er fra deg selv
    func isLastMessageFromCurrentUser(currentUserId: UUID) -> Bool {
        // denne funksjonaliteten må implementeres i databasen via last_message_sender_id
        return false
    }
}

// Eksisterende modeller (uendret)
struct Chat: Codable, Identifiable, Hashable {
    let id: UUID
    let ad_id: UUID? // KRITISK FIKS: Gjort valgfri (Optional)
    let starter_id: UUID
    let owner_id: UUID
    var expires_at: Date?
}

// Eksisterende modeller (uendret)
struct Message: Codable, Identifiable, Hashable {
    let id: Int64? // Skal være optional
    let chat_id: UUID
    let sender_id: UUID
    let body: String
    var created_at: Date?
}

// NY STRUCT: Payload for rapportering av melding
private struct MessageReportPayload: Encodable {
    let target_ad: String
    let reporter_id: String
    let reason: String
    
    enum CodingKeys: String, CodingKey {
        case target_ad = "target_ad"
        case reporter_id = "reporter_id"
        case reason = "reason"
    }
}


enum ChatRepository {

    // --- DEN NYE FUNKSJONEN SOM MANGLER HOS DEG ---
    static func fetchChatPreviews() async throws -> [ChatPreview] {
        // Kaller databasefunksjonen get_chat_previews
        let previews: [ChatPreview] = try await supabase
            .rpc("get_chat_previews")
            .execute()
            .value // Supabase dekoder JSON til [ChatPreview] for oss
        return previews
    }
    
    // --- Offentlige funksjoner ---
    static func fetchMessages(chatId: UUID) async throws -> [Message] { return try await fetchMessages_full(chatId: chatId) }
    static func sendMessage(chatId: UUID, text: String) async throws { try await sendMessage_full(chatId: chatId, text: text) }
    static func makeMessagesStream(chatId: UUID) -> (channel: RealtimeChannelV2, stream: AsyncStream<InsertAction>) { return makeMessagesStream_full(chatId: chatId) }
    static func startChat(for ad: Ad) async throws -> UUID { return try await startChat_full(for: ad) }

    // FIKS: Legger til den offentlige wrapper-funksjonen
    static func reportMessage(message: Message, reason: String) async throws { return try await reportMessage_full(message: message, reason: reason) }
    
    // NY FUNKSJON: Rapporterer en melding (Nå omdøpt til _full)
    private static func reportMessage_full(message: Message, reason: String) async throws {
        
        let reporterId: UUID
        do {
            // Henter ID (kaster feil om ikke innlogget)
            reporterId = try await supabase.auth.session.user.id
        } catch {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Bruker er ikke logget inn."])
        }
        
        // Henter annonse-ID
        let adId = try await fetchAdIdForChat(chatId: message.chat_id)
        
        // FIKS: Sender kun dataene som støttes av 'reports' tabellen
        let fullReason = "Melding: \"\(message.body)\". Årsak: \(reason) (Avsender: \(message.sender_id.uuidString))"
        
        let reportPayload = MessageReportPayload(
            target_ad: adId.uuidString, // Setter annonse-ID som mål
            reporter_id: reporterId.uuidString,
            reason: fullReason // Setter all info i reason-feltet
        )
        
        // FIKS: Bruker den eksisterende 'reports' tabellen
        _ = try await supabase.from("reports").insert(reportPayload).execute()
    }
    
    // NY HJELPEFUNKSJON: For å hente annonse-ID fra chat-ID
    private static func fetchAdIdForChat(chatId: UUID) async throws -> UUID {
        // Henter ALLE kolonner ("*")
        let chat: Chat = try await supabase
            .from("chats")
            .select("*")
            .eq("id", value: chatId)
            .single()
            .execute()
            .value
        
        // NÅ BLIR DENNE GUARD LET'en RIKTIG, siden ad_id er optional i structen
        guard let finalAdId = chat.ad_id else {
            throw NSError(domain: "DataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Chat har ingen tilknyttet annonse-ID."])
        }
        return finalAdId
    }
    
    // Private hjelpefunksjoner (uendret)
    private static func fetchMessages_full(chatId: UUID) async throws -> [Message] { return try await supabase.from("messages").select().eq("chat_id",value:chatId).order("created_at",ascending:true).execute().value }
    private static func sendMessage_full(chatId: UUID, text: String) async throws { let sId = try await supabase.auth.session.user.id; let m = Message(id:nil,chat_id:chatId,sender_id:sId,body:text,created_at:Date()); try await supabase.from("messages").insert(m).execute() }
    private static func makeMessagesStream_full(chatId: UUID) -> (channel: RealtimeChannelV2, stream: AsyncStream<InsertAction>) { let ch=supabase.realtimeV2.channel("public:messages"); let s=ch.postgresChange(InsertAction.self,schema:"public",table:"messages",filter:.eq("chat_id",value:chatId.uuidString)); return (ch,s) }
    private static func startChat_full(for ad: Ad) async throws -> UUID { guard let adId=ad.id else {throw NSError(domain: "StartChatError", code: 1)}; return try await supabase.rpc("start_chat",params:["ad_id_input":adId]).execute().value }
}
