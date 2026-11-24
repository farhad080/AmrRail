import SwiftUI

// MARK: - MainTabView
// Main application dashboard with 4 tabs, each using its own independent NavigationStack
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var trainViewModel: TrainViewModel
    @EnvironmentObject var favouritesViewModel: FavouritesViewModel
    @EnvironmentObject var diaryViewModel: DiaryViewModel

    var body: some View {
        TabView {
            // Tab 1: Trains (Train schedule browser with search & route filters)
            TrainListView()
                .tabItem {
                    Label("Trains", systemImage: "tram.fill")
                }

            // Tab 2: Favourites (Bookmarked trains with quick schedule access)
            FavouritesView()
                .tabItem {
                    Label("Favourites", systemImage: "heart.fill")
                }

            // Tab 3: Diary (Personal journey log with travel statistics)
            DiaryView()
                .tabItem {
                    Label("Diary", systemImage: "book.fill")
                }

            // Tab 4: Profile (User account details, stats summary, and log out)
            ProfileView()
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
