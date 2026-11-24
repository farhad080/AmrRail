import SwiftUI

// MARK: - DiaryView
// Displays travel statistics and past journeys with swipe-to-delete, tap-to-edit, and empty state
struct DiaryView: View {
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    @EnvironmentObject var trainViewModel: TrainViewModel

    // Sheet presentation state
    @State private var isShowingAddEditSheet: Bool = false
    @State private var journeyToEdit: JourneyEntry? = nil

    var body: some View {
        NavigationStack {
            List {
                // MARK: - 1. Travel Stats Section at the Top
                Section {
                    StatsView()
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)

                // MARK: - 2. Journey Entries Section
                Section("Trip History") {
                    if diaryViewModel.isLoading && diaryViewModel.entries.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView("Loading trips...")
                            Spacer()
                        }
                        .padding()
                    } else if diaryViewModel.entries.isEmpty {
                        // Empty State within the list
                        VStack(spacing: 12) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("No Journeys Recorded Yet")
                                .font(.headline)
                            Text("Tap the '+' button above to record your first train trip.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        ForEach(diaryViewModel.entries) { entry in
                            Button {
                                // Tap-to-edit: sets selected entry and opens modal sheet
                                journeyToEdit = entry
                                isShowingAddEditSheet = true
                            } label: {
                                JourneyEntryRowView(entry: entry)
                            }
                            .buttonStyle(.plain) // Prevents blue link selection style
                        }
                        .onDelete(perform: diaryViewModel.deleteJourneys)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Journey Diary")
            .toolbar {
                // "+" Toolbar button to log a new trip
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        journeyToEdit = nil // Clear edit target for new entry
                        isShowingAddEditSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                }
            }
            // Sheet for Adding or Editing a Journey
            .sheet(isPresented: $isShowingAddEditSheet) {
                AddEditJourneyView(
                    isPresented: $isShowingAddEditSheet,
                    journeyToEdit: journeyToEdit
                )
            }
            // MARK: - Listener Lifecycle in onAppear / onDisappear
            .onAppear {
                diaryViewModel.startListening()
            }
            .onDisappear {
                diaryViewModel.stopListening()
            }
        }
    }
}

// MARK: - JourneyEntryRowView
// Row layout displaying train name, route, date, and notes
struct JourneyEntryRowView: View {
    let entry: JourneyEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Train Name & Travel Date
            HStack {
                Text(entry.trainName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Route: From ➔ To
            HStack(spacing: 6) {
                Text(entry.from)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(entry.to)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Notes Preview (if user wrote notes)
            if !entry.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(entry.notes)
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DiaryView()
        .environmentObject(DiaryViewModel())
        .environmentObject(TrainViewModel())
}
