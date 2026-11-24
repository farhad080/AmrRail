import Foundation

// MARK: - TrainViewModel
// Manages train schedule data, search filtering, and route selection
class TrainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var trains: [Train] = []                 // Complete list of loaded trains
    @Published var searchText: String = ""              // Search query for train name or stations
    @Published var selectedRoute: String = "All"        // Selected route filter (e.g. "Dhaka ➔ Sylhet")
    @Published var errorMessage: String? = nil          // Error message if loading fails
    @Published var isLoading: Bool = false              // Controls loading spinner

    init() {
        loadTrainSchedules()
    }

    // MARK: - Data Loading
    /// Loads trains from the local trains.json bundle using TrainService
    func loadTrainSchedules() {
        // Avoid reloading if trains are already loaded
        guard trains.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            self.trains = try TrainService.shared.loadTrains()
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    // MARK: - Unique Routes for Filter Menu
    /// Generates a sorted list of unique routes extracted from the train list
    var availableRoutes: [String] {
        let routes = trains.map { "\($0.from) ➔ \($0.to)" }
        let unique = Array(Set(routes)).sorted()
        return ["All"] + unique
    }

    // MARK: - Computed Filtered Trains
    /// Computes filtered trains based on the active route filter and search text
    var filteredTrains: [Train] {
        trains.filter { train in
            // 1. Route filter match
            let routeMatches: Bool
            if selectedRoute == "All" {
                routeMatches = true
            } else {
                let currentRoute = "\(train.from) ➔ \(train.to)"
                routeMatches = (currentRoute == selectedRoute)
            }

            // 2. Search query match (Train name, origin, destination, or ANY station stop)
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if query.isEmpty {
                return routeMatches
            }

            let nameMatches = train.name.localizedCaseInsensitiveContains(query)
            let fromMatches = train.from.localizedCaseInsensitiveContains(query)
            let toMatches = train.to.localizedCaseInsensitiveContains(query)
            let stationMatches = train.stops.contains { stop in
                stop.station.localizedCaseInsensitiveContains(query)
            }

            return routeMatches && (nameMatches || fromMatches || toMatches || stationMatches)
        }
    }
}
