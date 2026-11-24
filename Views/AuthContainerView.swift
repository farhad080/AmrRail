import SwiftUI

// MARK: - AuthContainerView
// Container view that switches between LoginView and SignUpView using a local @State toggle
struct AuthContainerView: View {
    // Local state controlling which authentication screen is visible
    @State private var isShowingSignUp: Bool = false

    var body: some View {
        NavigationStack {
            if isShowingSignUp {
                // Passes $isShowingSignUp as a @Binding so SignUpView can toggle back
                SignUpView(isShowingSignUp: $isShowingSignUp)
                    .transition(.move(edge: .trailing))
            } else {
                // Passes $isShowingSignUp as a @Binding so LoginView can toggle forward
                LoginView(isShowingSignUp: $isShowingSignUp)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: isShowingSignUp)
    }
}

#Preview {
    AuthContainerView()
        .environmentObject(AuthViewModel())
}
