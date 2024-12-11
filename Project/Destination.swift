import SwiftUI

struct Destination: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let description: String
    let imageName: String
    let popularityScore: Int
    let locationId: String
    
    static let popular = [
        Destination(
            name: "Paris",
            country: "France",
            description: "The City of Light featuring the Eiffel Tower and world-class cuisine",
            imageName: "building.columns.fill",
            popularityScore: 98,
            locationId: "187147"
        ),
        Destination(
            name: "Bali",
            country: "Indonesia",
            description: "Tropical paradise with beautiful beaches and rich culture",
            imageName: "leaf.fill",
            popularityScore: 95,
            locationId: "294226"
        ),
        Destination(
            name: "Tokyo",
            country: "Japan",
            description: "Modern metropolis blending traditional culture with cutting-edge technology",
            imageName: "building.2.fill",
            popularityScore: 94,
            locationId: "298184"
        ),
        Destination(
            name: "Santorini",
            country: "Greece",
            description: "Stunning white-washed buildings overlooking the Aegean Sea",
            imageName: "sun.max.fill",
            popularityScore: 92,
            locationId: "189433"
        ),
        Destination(
            name: "New York City",
            country: "USA",
            description: "The Big Apple - world's most iconic cityscape and cultural hub",
            imageName: "building.fill",
            popularityScore: 91,
            locationId: "60763"
        )
    ]
} 