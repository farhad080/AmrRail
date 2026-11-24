import SwiftUI

// MARK: - MainTabView
// Main application dashboard displayed once a user is authenticated
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var trainViewModel: TrainViewModel
    @EnvironmentObject var diaryViewModel: DiaryViewModel

    var body: some View {
        TabView {
            // Tab 1: Schedules (Train list)
            NavigationStack {
                ContentView()
            }
            .tabItem {
                Label("Schedules", systemImage: "tram.fill")
            }

            // Tab 2: Journey Diary
            NavigationStack {
                VStack(spacing: 16) {
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.green)
                    Text("Journey Diary")
                        .font(.title2.bold())
                    Text("Your saved trips and notes will appear here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .navigationTitle("My Diary")
            }
            .tabItem {
                Label("Diary", systemImage: "book.fill")
            }

            // Tab 3: User Profile & Logout
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
                            authViewModel.logOut()
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
        .environmentObject(DiaryViewModel())
}
