import SwiftUI

// MARK: - FavouritesView
// Lists user's bookmarked trains with swipe-to-delete and navigation to train details
struct FavouritesView: View {
    @EnvironmentObject var favouritesViewModel: FavouritesViewModel
    @EnvironmentObject var trainViewModel: TrainViewModel

    var body: some View {
        NavigationStack {
            Group {
                if favouritesViewModel.isLoading && favouritesViewModel.favourites.isEmpty {
                    ProgressView("Loading favourites...")
                } else if favouritesViewModel.favourites.isEmpty {
                    ContentUnavailableView(
                        "No Favourites Yet",
                        systemImage: "heart.slash",
                        description: Text("Tap the heart icon on any train to quickly access its schedule here.")
                    )
                } else {
                    List {
                        ForEach(favouritesViewModel.favourites) { fav in
                            // Match full train schedule to navigate to detail view
                            if let train = trainViewModel.trains.first(where: { $0.id == fav.trainId }) {
                                NavigationLink {
                                    TrainDetailView(train: train)
                                } label: {
                                    FavouriteRowView(favourite: fav)
                                }
                            } else {
                                FavouriteRowView(favourite: fav)
                            }
                        }
                        .onDelete(perform: favouritesViewModel.deleteFavourites)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Favourites")
            // MARK: - Listener Lifecycle in onAppear / onDisappear
            // Start listening when user opens this screen
            .onAppear {
                favouritesViewModel.startListening()
            }
            // Stop listening when user leaves this screen to save bandwidth and battery
            .onDisappear {
                favouritesViewModel.stopListening()
            }
        }
    }
}

// MARK: - FavouriteRowView
// Row layout for individual favourite item
struct FavouriteRowView: View {
    let favourite: FavouriteTrain

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.title3)
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(favourite.trainName)
                        .font(.headline)
                    Spacer()
                    Text("#\(favourite.trainId)")
                        .font(.caption.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.12))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                }

                HStack(spacing: 4) {
                    Text(favourite.from)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                    Text(favourite.to)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FavouritesView()
        .environmentObject(FavouritesViewModel())
        .environmentObject(TrainViewModel())
}
