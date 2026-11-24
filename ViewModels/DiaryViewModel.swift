import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - DiaryViewModel
// Handles full CRUD operations for journey logs stored at users/{uid}/journeys
class DiaryViewModel: ObservableObject {
    @Published var entries: [JourneyEntry] = []  // User's saved journey logs
    @Published var errorMessage: String? = nil   // Error tracking for UI
    @Published var isLoading: Bool = false       // Activity indicator state

    // Real-time Firestore snapshot listener handle
    private var listenerRegistration: ListenerRegistration?

    init() {
        startListening()
    }

    deinit {
        // Prevent memory leak by removing the listener on deallocation
        stopListening()
    }

    // MARK: - 1. Snapshot Listener Lifecycle
    /// Attaches a real-time listener to users/{uid}/journeys ordered by date descending
    func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.entries = []
            return
        }

        // Avoid attaching multiple duplicate listeners
        guard listenerRegistration == nil else { return }

        isLoading = true
        let db = Firestore.firestore()

        listenerRegistration = db.collection("users")
            .document(uid)
            .collection("journeys")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }

                    guard let documents = snapshot?.documents else { return }
                    self?.entries = documents.compactMap { doc -> JourneyEntry? in
                        try? doc.data(as: JourneyEntry.self)
                    }
                }
            }
    }

    /// Detaches the Firestore snapshot listener
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }

    // MARK: - 2. Add Journey (Create)
    /// Saves a newly recorded trip into Firestore
    func addJourney(trainName: String, from: String, to: String, date: Date, notes: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Please log in to save journeys."
            return
        }

        let db = Firestore.firestore()
        let newEntry = JourneyEntry(
            id: nil, // Firestore auto-generates document ID
            trainName: trainName,
            from: from,
            to: to,
            date: date,
            notes: notes
        )

        do {
            _ = try db.collection("users")
                .document(uid)
                .collection("journeys")
                .addDocument(from: newEntry)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - 3. Update Journey (Update)
    /// Modifies an existing journey document in Firestore
    func updateJourney(entry: JourneyEntry) {
        guard let uid = Auth.auth().currentUser?.uid, let docId = entry.id else {
            self.errorMessage = "Missing journey document ID."
            return
        }

        let db = Firestore.firestore()
        do {
            try db.collection("users")
                .document(uid)
                .collection("journeys")
                .document(docId)
                .setData(from: entry)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - 4. Delete Journey (Delete)
    /// Deletes a specific journey document from Firestore
    func deleteJourney(entry: JourneyEntry) {
        guard let uid = Auth.auth().currentUser?.uid, let docId = entry.id else { return }

        let db = Firestore.firestore()
        db.collection("users")
            .document(uid)
            .collection("journeys")
            .document(docId)
            .delete { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
    }

    /// Deletes journey entries via swipe-to-delete in a List
    func deleteJourneys(at offsets: IndexSet) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        for index in offsets {
            let entry = entries[index]
            if let docId = entry.id {
                db.collection("users")
                    .document(uid)
                    .collection("journeys")
                    .document(docId)
                    .delete()
            }
        }
    }
}
