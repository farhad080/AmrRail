import Foundation
import FirebaseFirestore

// MARK: - DiaryViewModel
// Manages personal journey diary entries synced with Cloud Firestore
class DiaryViewModel: ObservableObject {
    @Published var entries: [JourneyEntry] = []  // User's saved journey logs
    @Published var errorMessage: String? = nil   // Error tracking for UI
    @Published var isLoading: Bool = false       // Activity indicator state
}
