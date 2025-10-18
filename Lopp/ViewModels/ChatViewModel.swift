// Filnavn: ChatViewModel.swift
import Foundation; import Combine; import Supabase
@MainActor final class ChatViewModel: ObservableObject {
    let chatId: UUID;
    @Published var messages: [Message] = [];
    @Published var reportSuccess: Bool = false // NYTT: Status for rapportering
    @Published var reportError: String?        // NYTT: Feilmelding for rapportering
    
    private var channel: RealtimeChannelV2?;
    private var streamTask: Task<Void, Never>?
    private static let supabaseDecoder: JSONDecoder = { let d=JSONDecoder(); let i=ISO8601DateFormatter(); i.formatOptions=[.withInternetDateTime,.withFractionalSeconds]; let p=ISO8601DateFormatter(); p.formatOptions=[.withInternetDateTime]; d.dateDecodingStrategy = .custom { c in let v=try c.singleValueContainer(); let s=try v.decode(String.self); if let dt=i.date(from:s){return dt}; if let dt=p.date(from:s){return dt}; throw DecodingError.dataCorruptedError(in:v,debugDescription:"Ugyldig dato") }; return d }()
    
    init(chatId: UUID) { self.chatId = chatId }
    
    func sendMessage(text: String) { Task { do { try await ChatRepository.sendMessage(chatId: chatId, text: text) } catch { print("Send error: \(error)") } } }
    
    // NY FUNKSJON: Rapporterer melding
    func reportMessage(message: Message, reason: String) async {
        reportSuccess = false
        reportError = nil
        do {
            try await ChatRepository.reportMessage(message: message, reason: reason)
            reportSuccess = true
        } catch {
            reportError = error.localizedDescription
            print("Feil ved rapportering av melding: \(error.localizedDescription)")
        }
    }
    
    func subscribeToMessages() { Task { do { messages = try await ChatRepository.fetchMessages(chatId: chatId); let (ch, stream) = ChatRepository.makeMessagesStream(chatId: chatId); channel = ch; try await ch.subscribe(); print("✅ Subscribed!"); streamTask = Task { [weak self] in guard let self else { return }; for await insert in stream { print("📡 Received!"); do { let msg = try insert.decodeRecord(as: Message.self, decoder: Self.supabaseDecoder); await MainActor.run { if !self.messages.contains(where: { $0.id == msg.id }) { self.messages.append(msg) } } } catch { print("Decode error: \(error)") } } } } catch { print("Setup error: \(error)") } } }
    func unsubscribeFromMessages() { Task { streamTask?.cancel(); streamTask=nil; try? await channel?.unsubscribe(); channel=nil } }
}
