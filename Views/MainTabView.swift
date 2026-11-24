import SwiftUI

// MARK: - MainTabView
// Main application dashboard displayed once a user is authenticated
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var trainViewModel: TrainViewModel
    @EnvironmentObject var favouritesViewModel: FavouritesViewModel
    @EnvironmentObject var diaryViewModel: DiaryViewModel

    var body: some View {
        TabView {
            // Tab 1: Train Schedules Browser
            TrainListView()
                .tabItem {
                    Label("Schedules", systemImage: "tram.fill")
                }

            // Tab 2: Favourites List
            FavouritesView()
                .tabItem {
                    Label("Favourites", systemImage: "heart.fill")
                }

            // Tab 3: Journey Diary (CRUD enabled)
            DiaryView()
                .tabItem {
                    Label("Diary", systemImage: "book.fill")
                }

            // Tab 4: User Profile & Logout
            NavigationStack {
                List {
                    Section("Account Details") {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(authViewModel.user?.displayName ?? "AmrRail Passenger")
                                    .font(.headline)
                                Text(authViewModel.user?.email ?? "No Email")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Section {
                        Button(role: .destructive) {
                            authViewModel.logOut() // Triggers Firebase signOut
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
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .tint(.green)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(TrainViewModel())
        .environmentObject(FavouritesViewModel())
        .environmentObject(DiaryViewModel())
}
