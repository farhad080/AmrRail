import Foundation
import FirebaseAuth

// MARK: - AuthViewModel
// Manages authentication state (login, registration, logout, current user)
class AuthViewModel: ObservableObject {
    // Published property that triggers UI updates whenever login status changes
    @Published var user: User? = nil
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil

    init() {
        // Check if a user is already signed in on app launch
        self.user = Auth.auth().currentUser
        self.isAuthenticated = (self.user != nil)
    }
}
