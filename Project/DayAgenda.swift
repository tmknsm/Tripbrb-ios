import Foundation

enum ActivityCategory: String, CaseIterable {
    case car = "Car"
    case entertainment = "Entertainment"
    case flight = "Flight"
    case food = "Food"
    case hotel = "Hotel"
    case train = "Train"
    case misc = "Misc."
    
    var icon: String {
        switch self {
        case .car: return "car.fill"
        case .entertainment: return "ticket.fill"
        case .flight: return "airplane"
        case .food: return "fork.knife"
        case .hotel: return "bed.double.fill"
        case .train: return "tram.fill"
        case .misc: return "ellipsis"
        }
    }
}

struct DayAgenda: Identifiable {
    let id = UUID()
    let date: Date
    var activities: [ScheduledActivity]
}

struct ScheduledActivity: Identifiable {
    let id = UUID()
    var time: Date
    var name: String
    var description: String
    var category: ActivityCategory?
    var url: String?
    var photoData: Data?
} 