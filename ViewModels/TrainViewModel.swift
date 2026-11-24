import Foundation

// MARK: - TrainViewModel
// Manages the train schedule data, search filters, and favourite trains
class TrainViewModel: ObservableObject {
    @Published var trains: [Train] = []             // All loaded trains
    @Published var filteredTrains: [Train] = []     // Trains after search/filter
    @Published var searchText: String = ""          // User's station/train query
    @Published var errorMessage: String? = nil      // Error status for UI alerts
    @Published var isLoading: Bool = false          // Loading spinner toggle

    init() {
        loadTrainSchedules()
    }

    /// Loads trains from the local trains.json bundle using TrainService
    func loadTrainSchedules() {
        isLoading = true
        do {
            self.trains = try TrainService.shared.loadTrains()
            self.filteredTrains = self.trains
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
