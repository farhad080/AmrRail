import SwiftUI

// MARK: - TrainDetailView
// Shows detailed schedule, route information, and vertical timeline of station stops
struct TrainDetailView: View {
    let train: Train

    // Access shared FavouritesViewModel from the environment
    @EnvironmentObject var favouritesViewModel: FavouritesViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Route Card
                VStack(spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(train.name)
                                .font(.title2.bold())
                            Text("Intercity Train #\(train.id)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()

                        // Favourite Heart Button connected to Firestore
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                favouritesViewModel.toggleFavourite(train: train)
                            }
                        } label: {
                            Image(systemName: favouritesViewModel.isFavourite(train: train) ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(favouritesViewModel.isFavourite(train: train) ? .red : .gray)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }

                    Divider()

                    // Route Display
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text("From")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(train.from)
                                .font(.headline)
                        }

                        Spacer()

                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("To")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(train.to)
                                .font(.headline)
                        }
                    }

                    // Off-Day Banner
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Weekly Off Day: **\(train.offDay)**")
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                .padding(.horizontal)

                // Route Timeline Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Route Timeline (\(train.stops.count) Stops)")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Vertical Stops Timeline
                    VStack(spacing: 0) {
                        ForEach(Array(train.stops.enumerated()), id: \.offset) { index, stop in
                            StopTimelineRow(
                                stop: stop,
                                isFirst: index == 0,
                                isLast: index == train.stops.count - 1
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(train.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - StopTimelineRow
// Individual station stop row formatted like a train journey timeline
struct StopTimelineRow: View {
    let stop: Stop
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline graphics (vertical line + circular node)
            VStack(spacing: 0) {
                // Top line segment
                Rectangle()
                    .fill(isFirst ? Color.clear : Color.green)
                    .frame(width: 2, height: 16)

                // Stop node icon
                Image(systemName: isFirst ? "record.circle.fill" : (isLast ? "circle.inset.filled" : "circle.fill"))
                    .font(.system(size: isFirst || isLast ? 14 : 10))
                    .foregroundStyle(isFirst ? .green : (isLast ? .red : .secondary))

                // Bottom line segment
                Rectangle()
                    .fill(isLast ? Color.clear : Color.green)
                    .frame(width: 2, height: 36)
            }
            .frame(width: 20)

            // Station Name & Arrival/Departure Times
            VStack(alignment: .leading, spacing: 4) {
                Text(stop.station)
                    .font(.body.weight(isFirst || isLast ? .bold : .medium))
                    .foregroundStyle(isFirst || isLast ? .primary : .secondary)

                HStack(spacing: 16) {
                    Label("Arr: \(stop.arrival)", systemImage: "arrow.down.right")
                        .font(.caption)
                        .foregroundStyle(stop.arrival == "Starts" ? .green : .secondary)

                    Label("Dep: \(stop.departure)", systemImage: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(stop.departure == "Ends" ? .red : .secondary)
                }
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        TrainDetailView(
            train: Train(
                id: "701",
                name: "Subarna Express",
                from: "Chattogram",
                to: "Dhaka",
                offDay: "Monday",
                stops: [
                    Stop(station: "Chattogram", arrival: "Starts", departure: "07:00 AM"),
                    Stop(station: "Feni", arrival: "08:15 AM", departure: "08:18 AM"),
                    Stop(station: "Cumilla", arrival: "09:05 AM", departure: "09:08 AM"),
                    Stop(station: "Dhaka Airport", arrival: "11:45 AM", departure: "11:50 AM"),
                    Stop(station: "Dhaka (Kamalapur)", arrival: "12:15 PM", departure: "Ends")
                ]
            )
        )
        .environmentObject(FavouritesViewModel())
    }
}
