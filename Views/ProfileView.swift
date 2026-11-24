import SwiftUI

// MARK: - ProfileView
// Tab screen displaying user profile details, travel stats summary, and log out action
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    @EnvironmentObject var favouritesViewModel: FavouritesViewModel

    @State private var showLogoutConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            List {
                // Section 1: User Identity Card
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .foregroundStyle(.green)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(authViewModel.user?.displayName ?? "AmrRail Passenger")
                                .font(.title3.bold())

                            Text(authViewModel.user?.email ?? "No email provided")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                // Section 2: Travel Stats Summary
                Section("Travel Activity Summary") {
                    StatsView()
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                }

                // Section 3: App Information
                Section("About AmrRail") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0 (Lab Project)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Backend", systemImage: "flame.fill")
                        Spacer()
                        Text("Firebase & Firestore")
                            .foregroundStyle(.secondary)
                    }
                }

                // Section 4: Log Out
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out")
                            Spacer()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Profile")
            .confirmationDialog("Log Out", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) {
                    // Detach listeners and clear state before signing out
                    favouritesViewModel.reset()
                    diaryViewModel.reset()
                    authViewModel.logOut()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out of AmrRail?")
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(DiaryViewModel())
        .environmentObject(FavouritesViewModel())
}
