import SwiftUI

// MARK: - LoginView
// Screen for existing users to sign in with email and password
struct LoginView: View {
    // Reads shared authentication state and actions from the environment
    @EnvironmentObject var authViewModel: AuthViewModel

    // Two-way binding to parent state to toggle between Login and SignUp screens
    @Binding var isShowingSignUp: Bool

    // Local view states for form inputs and error alerts
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Banner
                VStack(spacing: 8) {
                    Image(systemName: "tram.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    
                    Text("AmrRail")
                        .font(.largeTitle.bold())
                    
                    Text("Log in to plan journeys & save diary logs")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // Input Form Fields
                VStack(spacing: 16) {
                    // Email Field
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        TextField("Email Address", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    // Password Field
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        SecureField("Password (min 6 chars)", text: $password)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)

                // Login Action Button
                Button {
                    handleLogin()
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Log In")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .disabled(authViewModel.isLoading)

                // Toggle to Sign Up screen
                HStack {
                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)
                    Button("Sign Up") {
                        isShowingSignUp = true // Changes parent's binding
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                }
                .font(.subheadline)
                .padding(.top, 8)
            }
            .padding(.bottom, 30)
        }
        // Shows validation or Firebase error alerts
        .alert("Login Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        // Syncs Firebase errorMessage into the local alert
        .onChange(of: authViewModel.errorMessage) { _, newError in
            if let error = newError {
                alertMessage = error
                showAlert = true
            }
        }
    }

    // MARK: - Validation Logic
    private func handleLogin() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. Check for empty fields
        if trimmedEmail.isEmpty || trimmedPassword.isEmpty {
            alertMessage = "Please fill in both email and password."
            showAlert = true
            return
        }

        // 2. Validate password length (Firebase requires >= 6 chars)
        if trimmedPassword.count < 6 {
            alertMessage = "Password must be at least 6 characters long."
            showAlert = true
            return
        }

        // 3. Trigger Firebase sign-in via ViewModel
        authViewModel.logIn(email: trimmedEmail, password: trimmedPassword)
    }
}
