// Filnavn: CustomTabBar.swift
import SwiftUI

enum Tab {
    case explore, messages, myPage
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    var onPlusButtonTapped: () -> Void

    var body: some View {
        HStack {
            Spacer()
            // FIKS: Legger til en eksplisitt handling for å tvinge nullstilling i TabBarView
            TabBarButton(systemImage: "sparkle.magnifyingglass", text: "Utforsk", isActive: selectedTab == .explore) {
                selectedTab = .explore // Setter tab for å trigge onChange i TabBarView
            }
            Spacer()
            TabBarButton(systemImage: "message", text: "Meldinger", isActive: selectedTab == .messages) {
                selectedTab = .messages
            }
            Spacer()
            Button(action: onPlusButtonTapped) {
                VStack(spacing: 2) {
                    Image(systemName: "plus.circle.fill").font(.title)
                    Text("Ny annonse").font(.caption)
                }
                .foregroundColor(.appPrimary)
            }
            .frame(width: 80)
            Spacer()
            TabBarButton(systemImage: "person", text: "Min side", isActive: selectedTab == .myPage) {
                selectedTab = .myPage
            }
            Spacer()
        }
        .frame(height: 60)
        .padding(.horizontal)
        .background(.thinMaterial)
        .cornerRadius(30)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct TabBarButton: View {
    let systemImage: String
    let text: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: systemImage).font(.title2)
                Text(text).font(.caption)
            }
            .foregroundColor(isActive ? .appPrimary : .secondary)
        }
        .frame(width: 60)
    }
}
