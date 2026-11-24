import SwiftUI

// MARK: - Root ContentView Placeholder
// Root navigation container that accesses the injected environment ViewModels
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var trainViewModel: TrainViewModel
    @EnvironmentObject var diaryViewModel: DiaryViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "tram.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(.green)

                Text("AmrRail")
                    .font(.largeTitle.bold())

                Text("Bangladesh Train Schedule & Journey Diary")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text("Loaded \(trainViewModel.trains.count) trains successfully")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(TrainViewModel())
        .environmentObject(DiaryViewModel())
}
