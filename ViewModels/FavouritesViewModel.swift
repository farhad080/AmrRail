import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - FavouritesViewModel
// Manages real-time sync of user's favourite trains stored in Firestore at users/{uid}/favourites
class FavouritesViewModel: ObservableObject {
    @Published var favourites: [FavouriteTrain] = []     // Synced list of user's favourite trains
    @Published var errorMessage: String? = nil           // Tracks error messages for alerts
    @Published var isLoading: Bool = false               // Controls loading indicator

    // Handle for the active Firestore real-time snapshot listener
    private var listenerRegistration: ListenerRegistration?

    init() {
        startListening()
    }

    deinit {
        // Always detach listener when ViewModel is deallocated
        stopListening()
    }

    // MARK: - 1. Snapshot Listener Lifecycle
    /// Starts real-time listening to the user's favourites subcollection in Firestore
    func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.favourites = []
            return
        }

        // Avoid attaching multiple duplicate listeners
        guard listenerRegistration == nil else { return }

        isLoading = true
        let db = Firestore.firestore()

        listenerRegistration = db.collection("users")
            .document(uid)
            .collection("favourites")
            .order(by: "addedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }

                    guard let documents = snapshot?.documents else { return }
                    self?.favourites = documents.compactMap { doc -> FavouriteTrain? in
                        try? doc.data(as: FavouriteTrain.self)
                    }
                }
            }
    }

    /// Detaches the Firestore snapshot listener to save battery and network bandwidth
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }

    /// Resets the favourites state and cancels the snapshot listener (used during logout)
    func reset() {
        stopListening()
        favourites = []
    }

    // MARK: - 2. Query Helper
    /// Checks whether a given train is currently in the favourites list
    func isFavourite(train: Train) -> Bool {
        return favourites.contains { $0.trainId == train.id }
    }

    // MARK: - 3. Toggle Favourite
    /// Adds or deletes a train in users/{uid}/favourites/{trainId}
    func toggleFavourite(train: Train) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Please log in to save favourite trains."
            return
        }

        let db = Firestore.firestore()
        // Using train.id as the document ID guarantees 1 document per train
        let docRef = db.collection("users")
            .document(uid)
            .collection("favourites")
            .document(train.id)

        if isFavourite(train: train) {
            // Document exists -> delete it
            docRef.delete { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        } else {
            // Document doesn't exist -> create and save it
            let newFav = FavouriteTrain(
                id: train.id,
                trainId: train.id,
                trainName: train.name,
                from: train.from,
                to: train.to,
                addedAt: Date()
            )
            do {
                try docRef.setData(from: newFav)
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - 4. Swipe to Delete
    /// Removes selected favourites via List swipe action
    func deleteFavourites(at offsets: IndexSet) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        for index in offsets {
            let favourite = favourites[index]
            let docId = favourite.id ?? favourite.trainId
            db.collection("users")
                .document(uid)
                .collection("favourites")
                .document(docId)
                .delete()
        }
    }
}
