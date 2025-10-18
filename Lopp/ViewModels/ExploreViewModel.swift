// Filnavn: ExploreViewModel.swift
import Foundation
import Combine
import CoreLocation

@MainActor
class ExploreViewModel: ObservableObject {
    
    private var locationManager = LocationManager()
    
    // AdType er definert her.
    enum FilterType: String, CaseIterable {
        case swap
        case want
        case service

        // --- KORREKT SYNTAKS HER ---
        var displayName: String {
            switch self {
            case .swap: return "Bytte"
            // FIKS: Oppdaterer til flertall for bedre UX
            case .want: return "Ønsker"
            case .service: return "Tjenester"
            }
        }
    }

    @Published var ads: [Ad] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedType: FilterType = .swap
    @Published var currentCity: String? = nil
    
    // NYTT: Lagrer brukerens nøyaktige posisjon for avstandsberegning
    @Published var userLatitude: Double? = nil
    @Published var userLongitude: Double?
    
    var filteredAndSortedAds: [Ad] {
        // Filtrerer først basert på type (case-insensitivt)
        let filtered = ads.filter { $0.type.lowercased() == selectedType.rawValue.lowercased() }
        
        // Sorterer basert på avstand hvis brukerposisjon er kjent
        guard let userLat = userLatitude, let userLon = userLongitude else {
            return filtered
        }
        
        let userLocation = CLLocation(latitude: userLat, longitude: userLon)
        
        return filtered.sorted { ad1, ad2 in
            // Hvis annonsen mangler posisjon, kommer den sist
            guard let ad1Lat = ad1.latitude, let ad1Lon = ad1.longitude else { return false }
            guard let ad2Lat = ad2.latitude, let ad2Lon = ad2.longitude else { return true }
            
            let loc1 = CLLocation(latitude: ad1Lat, longitude: ad1Lon)
            let loc2 = CLLocation(latitude: ad2Lat, longitude: ad2Lon)
            
            // Sammenligner avstanden i meter
            let distance1 = userLocation.distance(from: loc1)
            let distance2 = userLocation.distance(from: loc2)
            
            return distance1 < distance2
        }
    }

    // Kombinert funksjon for å hente posisjon og deretter annonser
    func initializeLocationAndFetchAds() {
        Task {
            await updateLocation() // Henter posisjon
            fetchAds() // Henter annonser (uten filtrering i repoet)
        }
    }
    
    func updateLocation() async {
        do {
            let location: CLLocation = try await locationManager.requestUserLocation()
            self.currentCity = try await locationManager.getCityFrom(location: location)
            // NYTT: Lagrer de nøyaktige koordinatene
            self.userLatitude = location.coordinate.latitude
            self.userLongitude = location.coordinate.longitude
        } catch {
            print("Kunne ikke hente posisjon for ExploreView: \(error.localizedDescription)")
            self.currentCity = nil
            self.userLatitude = nil
            self.userLongitude = nil
        }
    }

    func fetchAds() {
        if ads.isEmpty { isLoading = true }
        errorMessage = nil
        
        Task {
            do {
                // Henter annonser uten å sende by-filter
                self.ads = try await AdsRepository.fetchAds()
            } catch {
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                    print("Nettverksforespørsel ble avbrutt (normalt).")
                } else {
                    self.errorMessage = error.localizedDescription
                }
            }
            await MainActor.run { self.isLoading = false }
        }
    }
}
