import SwiftUI

// MARK: - AddEditJourneyView
// Modal sheet used for both creating a new journey log and editing an existing one
struct AddEditJourneyView: View {
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    @EnvironmentObject var trainViewModel: TrainViewModel

    // Two-way binding controlling sheet presentation from parent
    @Binding var isPresented: Bool

    // If nil, we are creating a new entry; if set, we are editing an existing entry
    var journeyToEdit: JourneyEntry? = nil

    // Local form fields
    @State private var selectedTrain: Train?
    @State private var travelDate: Date = Date()
    @State private var notes: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    // Computed flag to check if we are in Edit Mode
    private var isEditMode: Bool {
        journeyToEdit != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Train Selection
                Section("Train & Route") {
                    Picker("Select Train", selection: $selectedTrain) {
                        Text("Choose a Train").tag(nil as Train?)
                        ForEach(trainViewModel.trains) { train in
                            Text("\(train.name) (\(train.from) ➔ \(train.to))")
                                .tag(train as Train?)
                        }
                    }

                    if let train = selectedTrain {
                        HStack {
                            Text("Route")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(train.from) ➔ \(train.to)")
                                .fontWeight(.medium)
                        }
                        HStack {
                            Text("Train Number")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("#\(train.id)")
                                .fontWeight(.medium)
                        }
                    }
                }

                // Section 2: Date of Journey (Past Dates Only)
                Section("Travel Date") {
                    DatePicker(
                        "Date of Journey",
                        selection: $travelDate,
                        in: ...Date(), // Restricts selection to past dates and today only
                        displayedComponents: [.date]
                    )
                }

                // Section 3: Personal Notes & Memories
                Section("Journey Notes & Memories") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle(isEditMode ? "Edit Journey" : "Log New Journey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }

                // Save Button
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditMode ? "Update" : "Save") {
                        handleSave()
                    }
                    .fontWeight(.bold)
                }
            }
            // Populate form fields if editing an existing journey
            .onAppear {
                populateFieldsIfEditing()
            }
            .alert("Incomplete Information", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Populate Form on Edit
    private func populateFieldsIfEditing() {
        if let entry = journeyToEdit {
            self.travelDate = entry.date
            self.notes = entry.notes
            // Match train by name
            if let matched = trainViewModel.trains.first(where: { $0.name == entry.trainName }) {
                self.selectedTrain = matched
            }
        } else if selectedTrain == nil {
            // Default to first train if available
            selectedTrain = trainViewModel.trains.first
        }
    }

    // MARK: - Save or Update Action
    private func handleSave() {
        guard let train = selectedTrain else {
            alertMessage = "Please select a train for your journey."
            showAlert = true
            return
        }

        if let existing = journeyToEdit {
            // Edit Mode: Update existing Firestore document
            var updated = existing
            updated.trainName = train.name
            updated.from = train.from
            updated.to = train.to
            updated.date = travelDate
            updated.notes = notes

            diaryViewModel.updateJourney(entry: updated)
        } else {
            // Add Mode: Insert new document into Firestore
            diaryViewModel.addJourney(
                trainName: train.name,
                from: train.from,
                to: train.to,
                date: travelDate,
                notes: notes
            )
        }

        isPresented = false
    }
}

#Preview {
    AddEditJourneyView(
        isPresented: .constant(true),
        journeyToEdit: nil
    )
    .environmentObject(DiaryViewModel())
    .environmentObject(TrainViewModel())
}
