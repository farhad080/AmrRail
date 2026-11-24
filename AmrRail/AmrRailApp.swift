import SwiftUI
import FirebaseCore

// MARK: - AppDelegate for Firebase Configuration
// Uses the UIKit lifecycle hook to initialize Firebase services when the app launches
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configures Firebase (connects GoogleService-Info.plist)
        FirebaseApp.configure()
        return true
    }
}

// MARK: - Main App Entry Point
@main
struct AmrRailApp: App {
    // Links our AppDelegate to the SwiftUI lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // Creates single instances of our shared ViewModels at the root of the app
    // @StateObject ensures these instances survive view redrawing
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var trainViewModel = TrainViewModel()
    @StateObject private var diaryViewModel = DiaryViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Injects the ViewModels into the environment hierarchy
                // Any child view can now read them using @EnvironmentObject
                .environmentObject(authViewModel)
                .environmentObject(trainViewModel)
                .environmentObject(diaryViewModel)
        }
    }
}
