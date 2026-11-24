import Foundation

// MARK: - Stop Model
// Represents an individual station stop along a train's journey
struct Stop: Codable, Hashable, Identifiable {
    // Using station name as the unique identifier for List iteration
    var id: String { station }
    
    let station: String   // Name of the railway station (e.g. "Dhaka Airport")
    let arrival: String   // Scheduled arrival time (e.g. "07:30 AM" or "Starts")
    let departure: String // Scheduled departure time (e.g. "07:35 AM" or "Ends")
}
