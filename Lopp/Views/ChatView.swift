// Filnavn: ChatView.swift
import SwiftUI
import Supabase

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @StateObject private var detailViewModel: ChatDetailViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var messageText: String = ""
    
    // NYTT: State for å vise rapporteringsvindu
    @State private var showingReportMessageSheet: Message? = nil

    init(chatId: UUID) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(chatId: chatId))
        _detailViewModel = StateObject(wrappedValue: ChatDetailViewModel(chatId: chatId))
    }

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    // NYTT: Subtil hint for rapportering
                    Text("Trykk og hold på en melding for å rapportere den.")
                        .font(.caption2)
                        .foregroundColor(.appTextMuted)
                        .padding(.vertical, 8)
                    
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            let isCurrentUser = message.sender_id == authViewModel.user?.id
                            
                            MessageBubble(
                                message: message,
                                isCurrentUser: isCurrentUser,
                                participantName: self.participantName(for: message.sender_id),
                                currentUserId: authViewModel.user?.id
                            )
                            .id(message.id)
                            // ContextMenu for rapportering (langt trykk)
                            .contextMenu {
                                // Bruker kan ikke rapportere sine egne meldinger
                                if !isCurrentUser {
                                    Button(role: .destructive) {
                                        showingReportMessageSheet = message
                                    } label: {
                                        Label("Rapporter melding", systemImage: "flag")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .onChange(of: viewModel.messages) { _, newMessages in
                    if let lastMessage = newMessages.last {
                        withAnimation { scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom) }
                    }
                }
            }

            HStack {
                TextField("Skriv en melding...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.leading)
                Button {
                    viewModel.sendMessage(text: messageText); messageText = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(messageText.isEmpty ? .gray.opacity(0.5) : .appPrimary)
                }
                .padding(.trailing)
                .disabled(messageText.isEmpty)
            }
            .padding(.bottom)
        }
        .navigationTitle(detailViewModel.chatTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.subscribeToMessages()
            detailViewModel.fetchDetails()
        }
        .onDisappear { viewModel.unsubscribeFromMessages() }
        
        // NYTT: Sheet for Rapportering av Melding
        .sheet(item: $showingReportMessageSheet) { message in
            ReportMessageSheet(viewModel: viewModel, message: message)
        }
        // NYTT: Alert ved vellykket rapportering
        .alert("Takk", isPresented: $viewModel.reportSuccess) {
            Button("OK") {}
        } message: {
            Text("Meldingen er rapportert. Vi vil se gjennom innholdet.")
        }
        // NYTT: Alert ved feil under rapportering
        .alert("Feil", isPresented: .constant(viewModel.reportError != nil), presenting: viewModel.reportError) { _ in
            Button("OK") { viewModel.reportError = nil }
        } message: { error in
            Text(error)
        }
    }
    
    private func participantName(for userId: UUID) -> String {
        guard let currentUserID = authViewModel.user?.id else { return "Laster..." }
        
        if userId == currentUserID {
            return "Meg"
        }
        
        return detailViewModel.participantName ?? "Deltaker"
    }
}

// NY KOMPONENT: Sheet for Rapportering av Melding
struct ReportMessageSheet: View {
    @ObservedObject var viewModel: ChatViewModel
    let message: Message
    @State private var reason: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Text("Du rapporterer: \"\(message.body)\"")
                    .font(.headline)
                    .padding(.bottom)
                
                Section("Årsak") {
                    TextEditor(text: $reason)
                        .frame(minHeight: 100)
                }
                
                if let error = viewModel.reportError {
                    Text("Feil: \(error)").foregroundColor(.appError)
                }
            }
            .navigationTitle("Rapporter Melding")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Rapporter") {
                        Task {
                            await viewModel.reportMessage(message: message, reason: reason)
                            if viewModel.reportSuccess {
                                dismiss()
                            }
                        }
                    }
                    .disabled(reason.count < 10)
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    let participantName: String
    let currentUserId: UUID?
    
    @State private var showTimestamp: Bool = false
    
    private var timestampString: String {
        return message.created_at?.formatted(date: .omitted, time: .shortened) ?? ""
    }
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
            if !isCurrentUser {
                Text(participantName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                if isCurrentUser && showTimestamp {
                    Text(timestampString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Text(message.body)
                    .padding(12)
                    .background(isCurrentUser ? Color.appPrimary : Color(.systemGray5))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(18, corners: isCurrentUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                    .onTapGesture {
                        withAnimation {
                            showTimestamp.toggle()
                        }
                    }
                
                if !isCurrentUser && showTimestamp {
                    Text(timestampString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(.vertical, 4)
    }
}

// Hjelpe-extension for å runde spesifikke hjørner (uendret)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
