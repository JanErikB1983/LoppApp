// Filnavn: LocationManager.swift
import Foundation; import CoreLocation; import Combine; import MapKit
struct LocationResult { let coordinate: CLLocationCoordinate2D; let city: String }
@MainActor class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let manager = CLLocationManager(); @Published var authorizationStatus: CLAuthorizationStatus; private var continuation: CheckedContinuation<CLLocation, Error>?
    override init() { authorizationStatus = manager.authorizationStatus; super.init(); manager.delegate = self }
    func requestUserLocation() async throws -> CLLocation { manager.requestWhenInUseAuthorization(); return try await withCheckedThrowingContinuation { c in continuation = c; manager.requestLocation() } }
    func getCityFrom(location: CLLocation) async throws -> String { let geocoder=CLGeocoder(); guard let p=try await geocoder.reverseGeocodeLocation(location).first, let city=p.locality else { throw NSError()}; return city }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locs: [CLLocation]) { guard let l=locs.first else {return}; continuation?.resume(returning:l); continuation=nil }
    func locationManager(_ manager: CLLocationManager, didFailWithError err: Error) { continuation?.resume(throwing:err); continuation=nil }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { authorizationStatus = manager.authorizationStatus }
}
