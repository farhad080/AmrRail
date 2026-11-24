import Foundation
import FirebaseFirestore

// MARK: - FavouriteTrain Model
// Represents a train bookmarked by the user for fast schedule access
struct FavouriteTrain: Codable, Identifiable {
    @DocumentID var id: String? // Automatically mapped by Firestore to the document ID
    let trainId: String         // Train ID matching the Train model (e.g. "701")
    let trainName: String       // Cached train name for quick rendering
    let from: String            // Origin station
    let to: String              // Destination station
    let addedAt: Date           // Timestamp when user marked it as favourite
}
