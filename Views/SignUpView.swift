import SwiftUI

// MARK: - SignUpView
// Screen for new users to register with name, email, and password
struct SignUpView: View {
    // Reads shared authentication state and actions from the environment
    @EnvironmentObject var authViewModel: AuthViewModel

    // Two-way binding to toggle back to the LoginView
    @Binding var isShowingSignUp: Bool

    // Local form state
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Banner
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    
                    Text("Create Account")
                        .font(.largeTitle.bold())
                    
                    Text("Join AmrRail to track journeys and schedules")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // Input Form Fields
                VStack(spacing: 16) {
                    // Full Name Field
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        TextField("Full Name", text: $name)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

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

                    // Confirm Password Field
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        SecureField("Confirm Password", text: $confirmPassword)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)

                // Register Action Button
                Button {
                    handleSignUp()
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Create Account")
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

                // Toggle back to Login screen
                HStack {
                    Text("Already have an account?")
                        .foregroundStyle(.secondary)
                    Button("Log In") {
                        isShowingSignUp = false // Changes parent's binding
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
        .alert("Registration Error", isPresented: $showAlert) {
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
    private func handleSignUp() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. Check for empty fields
        if trimmedName.isEmpty || trimmedEmail.isEmpty || trimmedPassword.isEmpty {
            alertMessage = "All fields are required. Please fill them out."
            showAlert = true
            return
        }

        // 2. Validate password minimum length
        if trimmedPassword.count < 6 {
            alertMessage = "Password must be at least 6 characters long."
            showAlert = true
            return
        }

        // 3. Confirm password matching
        if trimmedPassword != trimmedConfirm {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }

        // 4. Trigger Firebase sign-up via ViewModel
        authViewModel.signUp(email: trimmedEmail, password: trimmedPassword, name: trimmedName)
    }
}
