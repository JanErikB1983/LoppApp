// Filnavn: MyPageView.swift
import SwiftUI
import Supabase

struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingEditProfile = false
    @State private var profileDidUpdate = false
    
    // NYTT: State for å bekrefte sletting av konto
    @State private var showingDeleteAccountAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Profil")) {
                    Button {
                        if viewModel.profileVM?.profile != nil {
                            isShowingEditProfile = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "person.circle.fill").resizable().frame(width: 50, height: 50).foregroundColor(.gray)
                            VStack(alignment: .leading) {
                                Text(viewModel.profileVM?.profile?.first_name ?? authViewModel.user?.email ?? "-").font(.headline).foregroundColor(.primary)
                                
                                if viewModel.profileVM?.isLoading == true && viewModel.profileVM?.profile == nil {
                                    Text("Laster profil...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Rediger profil").font(.subheadline).foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                Section(header: Text("Mine Annonser")) {
                    if viewModel.isLoading { ProgressView() }
                    else if let msg = viewModel.errorMessage { Text("Feil: \(msg)").foregroundColor(.red) }
                    else if viewModel.myAds.isEmpty { Text("Ingen annonser.") }
                    else { ForEach(viewModel.myAds) { ad in NavigationLink(value: ad) { AdCardView(ad: ad) } } }
                }
                
                Section(header: Text("Support")) {
                    NavigationLink("Om Lopp / Kontakt oss") {
                        AboutView()
                    }
                }
                
                Section {
                    Button("Logg ut", role: .destructive) { authViewModel.signOut() }
                    
                    // NYTT: Knapp for sletting av konto (Kritisk for Apple Review)
                    Button("Slett konto permanent", role: .destructive) {
                        showingDeleteAccountAlert = true
                    }
                    .disabled(viewModel.profileVM?.isLoading == true)
                }
            }
            .navigationTitle("Min side")
            .navigationDestination(for: Ad.self) { ad in
                AdDetailView(ad: ad)
            }
            .onAppear {
                if let userId = authViewModel.user?.id {
                    viewModel.loadData(userId: userId)
                }
            }
            .onChange(of: profileDidUpdate) { oldValue, newValue in
                if newValue {
                    profileDidUpdate = false
                }
            }
            .sheet(isPresented: $isShowingEditProfile) {
                if let profileVM = viewModel.profileVM {
                    EditProfileView(profileVM: profileVM, profileUpdated: $profileDidUpdate)
                }
            }
            // NYTT: Alert for sletting av konto
            .alert("Slett konto", isPresented: $showingDeleteAccountAlert) {
                Button("Slett permanent", role: .destructive) {
                    Task {
                        // Sjekker om VM er klar
                        if let profileVM = viewModel.profileVM {
                            let success = await profileVM.deleteAccount()
                            if success {
                                authViewModel.signOut() // AuthViewModel logger ut
                            }
                        }
                    }
                }
                Button("Avbryt", role: .cancel) {}
            } message: {
                Text("ADVARSEL: Dette vil slette din konto og alle data permanent i henhold til GDPR. Denne handlingen kan ikke angres.")
            }
            // NYTT: Alert for feil ved sletting
            .alert("Feil ved sletting", isPresented: .constant(viewModel.profileVM?.deleteAccountError != nil), presenting: viewModel.profileVM?.deleteAccountError) { _ in
                Button("OK") { viewModel.profileVM?.deleteAccountError = nil }
            } message: { error in
                Text(error)
            }
        }
    }
}
