import Foundation

// MARK: - TrainService Error Definitions
// Custom error enum to provide clear, human-readable error messages for debugging and viva explanation
enum TrainServiceError: LocalizedError {
    case fileNotFound(String)
    case dataLoadingFailed(Error)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "File '\(filename)' was not found in the main app bundle."
        case .dataLoadingFailed(let error):
            return "Failed to read data from bundle file: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to parse JSON into Train models: \(error.localizedDescription)"
        }
    }
}

// MARK: - TrainService
// Responsible for reading and parsing the static train schedules stored in trains.json
class TrainService {
    // Shared singleton instance so ViewModels can call TrainService.shared.loadTrains()
    static let shared = TrainService()

    // Private initializer prevents outside instantiation, enforcing the Singleton pattern
    private init() {}

    /// Loads and decodes train schedules from the app bundle.
    /// - Parameter filename: The name of the JSON file (without extension), defaults to "trains".
    /// - Returns: An array of decoded Train objects.
    /// - Throws: TrainServiceError indicating exactly where the operation failed.
    func loadTrains(from filename: String = "trains") throws -> [Train] {
        // Step 1: Locate the JSON file inside the app's bundle
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw TrainServiceError.fileNotFound("\(filename).json")
        }

        // Step 2: Read the raw binary Data from the file URL
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw TrainServiceError.dataLoadingFailed(error)
        }

        // Step 3: Decode JSON data into an array of Train Swift structs
        do {
            let decoder = JSONDecoder()
            let trains = try decoder.decode([Train].self, from: data)
            return trains
        } catch {
            throw TrainServiceError.decodingFailed(error)
        }
    }
}
