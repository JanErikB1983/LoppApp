//
//  AdType.swift
//  Lopp
//
//  Created by Kode-mester.
//

import Foundation

/// Definerer annonsetyper for bruk i alle ViewModels og Views.
enum AdType: String, Codable, CaseIterable, Identifiable {
    case swap
    case want
    case service
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .swap: return "Bytte"
        case .want: return "Ønske"
        case .service: return "Tjeneste"
        }
    }
}
