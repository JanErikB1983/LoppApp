// Filnavn: Lopp/Lopp/ViewModels/CreateAdViewModel.swift
import SwiftUI
import Combine
import PhotosUI
import CoreLocation

@MainActor
class CreateAdViewModel: ObservableObject {
    // AdType er definert globalt i CreateAdFlowView.swift
    
    enum Step: Hashable { case details, extraDetails, photos, location }
    enum ViewState: Equatable { case idle, loading, success, error(String) }

    private var locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>() // For Combine

    @Published var path = NavigationPath()
    @Published var viewState: ViewState = .idle
    @Published var adType: AdType?
    @Published var title = ""
    @Published var description = ""
    @Published var wantText = ""
    @Published var offerText = ""
    @Published var price = ""
    @Published var images: [UIImage] = []
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var city = "Ukjent"
    @Published var pickerItems: [PhotosPickerItem] = []

    init() {
        // Lytter på endringer i pickerItems
        $pickerItems
            .sink { [weak self] newItems in
                Task {
                    await self?.loadImages(from: newItems)
                }
            }
            .store(in: &cancellables)
    }

    func proceedFromDetails() {
        guard let _ = adType else { return }
        // ALLE annonsetyper må gå gjennom ExtraDetails for å fange opp felt
        path.append(CreateAdViewModel.Step.extraDetails)
    }

    func loadImages(from items: [PhotosPickerItem]) async {
        images.removeAll()
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                // Begrenser til maks 5 bilder totalt
                if images.count < 5 {
                    images.append(img)
                }
            }
        }
    }

    func publishAd() {
        guard let type = adType else { viewState = .error("Mangler type"); return }
        Task {
            viewState = .loading
            let datas = images.compactMap { ImageUtils.jpegDataScaled($0) }
            do {
                try await AdsRepository.createAd(
                    type: type.rawValue, title: title, description: description,
                    wantText: wantText, offerText: offerText, price: price,
                    latitude: latitude, longitude: longitude,
                    city: city == "Ukjent" ? nil : city, photos: datas
                )
                viewState = .success
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }

    func getLocation() {
        viewState = .loading
        Task {
            do {
                let loc = try await locationManager.requestUserLocation()
                let cityResult = try await locationManager.getCityFrom(location: loc)
                city = cityResult
                latitude = loc.coordinate.latitude
                longitude = loc.coordinate.longitude
                viewState = .idle
            } catch {
                viewState = .error(error.localizedDescription)
                city = "Ukjent"
            }
        }
    }
}
