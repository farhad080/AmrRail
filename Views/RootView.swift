import SwiftUI

// MARK: - RootView
// Decides whether to display the authentication flow or the authenticated main app
struct RootView: View {
    // Injected from AmrRailApp; observes real-time user authentication state
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.user != nil {
                // User is authenticated -> show MainTabView
                MainTabView()
            } else {
                // User is logged out / unauthenticated -> show Auth flow
                AuthContainerView()
            }
        }
        // Smooth transition animation when switching between auth and main views
        .animation(.easeInOut, value: authViewModel.user != nil)
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
}
