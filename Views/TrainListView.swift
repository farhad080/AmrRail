import SwiftUI

// MARK: - TrainListView
// Displays searchable, filterable Bangladesh Railway train schedules
struct TrainListView: View {
    // Reads shared ViewModels from the environment
    @EnvironmentObject var trainViewModel: TrainViewModel
    @EnvironmentObject var favouritesViewModel: FavouritesViewModel

    var body: some View {
        NavigationStack {
            Group {
                if trainViewModel.isLoading {
                    ProgressView("Loading train schedules...")
                } else if trainViewModel.filteredTrains.isEmpty {
                    // Empty search/filter result state
                    ContentUnavailableView(
                        "No Trains Found",
                        systemImage: "tram.fill",
                        description: Text("Try searching with another station name or reset the route filter.")
                    )
                } else {
                    List {
                        // Optional Active Filter Notice Chip
                        if trainViewModel.selectedRoute != "All" {
                            HStack {
                                Label("Route: \(trainViewModel.selectedRoute)", systemImage: "line.3.horizontal.decrease.circle.fill")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.green)
                                Spacer()
                                Button("Reset") {
                                    trainViewModel.selectedRoute = "All"
                                }
                                .font(.caption.bold())
                                .foregroundStyle(.red)
                            }
                            .listRowBackground(Color.green.opacity(0.1))
                        }

                        // Train Cards List
                        ForEach(trainViewModel.filteredTrains) { train in
                            NavigationLink {
                                TrainDetailView(train: train)
                            } label: {
                                TrainRowView(train: train)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Train Schedules")
            // Search Bar: searches train name OR any station stop
            .searchable(
                text: $trainViewModel.searchText,
                prompt: "Search train or station (e.g. Feni, Sylhet)"
            )
            // Route Filter Menu in Toolbar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Filter Route", selection: $trainViewModel.selectedRoute) {
                            ForEach(trainViewModel.availableRoutes, id: \.self) { route in
                                Text(route).tag(route)
                            }
                        }
                    } label: {
                        Label(
                            "Filter",
                            systemImage: trainViewModel.selectedRoute == "All"
                                ? "line.3.horizontal.decrease.circle"
                                : "line.3.horizontal.decrease.circle.fill"
                        )
                        .foregroundStyle(.green)
                    }
                }
            }
            // Ensures data is loaded when screen appears
            .onAppear {
                trainViewModel.loadTrainSchedules()
                favouritesViewModel.startListening()
            }
        }
    }
}

// MARK: - TrainRowView
// Custom card row displaying train summary info and favourite heart indicator
struct TrainRowView: View {
    let train: Train
    @EnvironmentObject var favouritesViewModel: FavouritesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Train Name, Heart Icon, and Train Number Badge
            HStack {
                Text(train.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                // Shows red filled heart if this train is marked as favourite
                if favouritesViewModel.isFavourite(train: train) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Spacer()

                Text("#\(train.id)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }

            // Route: From ➔ To
            HStack(spacing: 6) {
                Text(train.from)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(train.to)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            // Metadata: Off Day & Stops Count
            HStack {
                Label("Off: \(train.offDay)", systemImage: "calendar.badge.clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Label("\(train.stops.count) stops", systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TrainListView()
        .environmentObject(TrainViewModel())
        .environmentObject(FavouritesViewModel())
}
