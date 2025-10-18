// Filnavn: TabBarView.swift
import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: Tab = .explore
    @State private var isShowingCreateAdFlow = false
    
    // Nødvendig for å tvinge nullstilling av navigasjonsstakken
    @State private var exploreNavigationID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            // Viser innhold basert på valgt fane
            switch selectedTab {
            case .explore:
                // Bruker id-nøkkel for å tvinge fullstendig re-opprettelse/nullstilling
                ExploreView()
                    .id(exploreNavigationID)
            case .messages:
                MessagesView()
            case .myPage:
                MyPageView()
            }

            Spacer(minLength: 0)

            // Den egendefinerte tab-raden
            CustomTabBar(selectedTab: $selectedTab) {
                isShowingCreateAdFlow = true
            }
        }
        .sheet(isPresented: $isShowingCreateAdFlow) {
            CreateAdFlowView()
        }
        // FIKS: Tvinger nullstilling av ExploreView når knappen trykkes på nytt
        .onChange(of: selectedTab) { oldValue, newValue in
            // Hvis brukeren klikker på Explore når den allerede er valgt
            if newValue == .explore {
                // Siden `selectedTab` allerede er `.explore`, har verdien ikke endret seg.
                // Vi må derfor tvinge en endring av en annen variabel for å trigge View-oppdateringen.
                if oldValue == .explore {
                     exploreNavigationID = UUID() // Nullstiller stakken
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
