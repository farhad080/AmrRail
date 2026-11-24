import Foundation
import FirebaseFirestore

// MARK: - JourneyEntry Model
// Represents a personal trip log entry saved in Cloud Firestore
struct JourneyEntry: Codable, Identifiable {
    @DocumentID var id: String? // Firestore document ID populated automatically
    var trainName: String       // Name of the train taken
    var from: String            // Boarding station
    var to: String              // Destination station
    var date: Date              // Date of travel
    var notes: String           // Personal notes or reflections about the journey
}
