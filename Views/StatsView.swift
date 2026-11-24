import SwiftUI

// MARK: - StatsView
// Displays summary cards for total journeys and the most frequently used train
struct StatsView: View {
    @EnvironmentObject var diaryViewModel: DiaryViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Card 1: Total Journeys
            StatCardView(
                title: "Total Journeys",
                value: "\(diaryViewModel.totalJourneys)",
                subtitle: diaryViewModel.totalJourneys == 1 ? "trip recorded" : "trips recorded",
                icon: "tram.fill",
                color: .green
            )

            // Card 2: Most Used Train
            if let topTrain = diaryViewModel.mostUsedTrain {
                StatCardView(
                    title: "Top Train",
                    value: topTrain.name,
                    subtitle: "\(topTrain.count) \(topTrain.count == 1 ? "journey" : "journeys")",
                    icon: "star.fill",
                    color: .orange
                )
            } else {
                StatCardView(
                    title: "Top Train",
                    value: "None Yet",
                    subtitle: "Log your first trip",
                    icon: "star.slash",
                    color: .secondary
                )
            }
        }
    }
}

// MARK: - StatCardView
// Individual reusable card component for an individual metric
struct StatCardView: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.headline)
                Spacer()
            }

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(color)
                .textCase(.uppercase)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    StatsView()
        .environmentObject(DiaryViewModel())
}
