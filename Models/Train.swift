import Foundation

// MARK: - Train Model
// Represents an intercity train with route details, weekly off-day, and scheduled stops
struct Train: Codable, Identifiable, Hashable {
    let id: String        // Unique train identifier / train number (e.g. "701")
    let name: String      // Commercial name of the train (e.g. "Subarna Express")
    let from: String      // Origin station (e.g. "Chattogram")
    let to: String        // Destination station (e.g. "Dhaka")
    let offDay: String    // Weekly maintenance off-day (e.g. "Monday")
    let stops: [Stop]     // Sequential array of station stops
}
