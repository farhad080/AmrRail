import Foundation
import FirebaseAuth

// MARK: - AuthViewModel
// Handles user authentication state, Firebase calls, and auth listener lifecycle
class AuthViewModel: ObservableObject {
    // Published properties automatically notify observing SwiftUI views when their values change
    @Published var user: User? = nil             // Holds current Firebase user (nil if logged out)
    @Published var errorMessage: String? = nil   // Holds error message for display in UI alerts
    @Published var isLoading: Bool = false       // Toggles progress spinner during network requests

    // Listener handle to track user sign-in/sign-out state changes
    private var authListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Start listening to Firebase auth changes on creation
        startAuthStateListener()
    }

    deinit {
        // Memory cleanup: Remove the Firebase listener when ViewModel is deallocated
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - 1. Auth State Listener
    /// Attaches a real-time listener to Firebase to detect login/logout events automatically
    func startAuthStateListener() {
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            // Always update UI-bound properties on the main thread
            DispatchQueue.main.async {
                self?.user = user
            }
        }
    }

    // MARK: - 2. Sign Up
    /// Creates a new user in Firebase Auth and sets their display name
    func signUp(email: String, password: String, name: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    return
                }

                // If user creation succeeded, update the profile display name
                if let user = authResult?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = name
                    changeRequest.commitChanges { profileError in
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            if let profileError = profileError {
                                self?.errorMessage = profileError.localizedDescription
                            } else {
                                // Reload user so displayName is immediately visible in the app
                                self?.user = Auth.auth().currentUser
                            }
                        }
                    }
                } else {
                    self?.isLoading = false
                }
            }
        }
    }

    // MARK: - 3. Log In
    /// Authenticates an existing user with email and password
    func logIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.user = authResult?.user
            }
        }
    }

    // MARK: - 4. Log Out
    /// Signs out the current user from Firebase
    func logOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
