import UIKit
import UserNotifications
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Configure Firebase
        FirebaseApp.configure()

        // Set up notifications
        setupNotifications(application)

        // Set messaging delegate
        Messaging.messaging().delegate = self

        return true
    }

    private func setupNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }

        application.registerForRemoteNotifications()
    }

    // MARK: - Push Notification Handling

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error)")
    }

    // MARK: - UNUserNotificationCenterDelegate

    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // Handle notification data
        if let urlString = userInfo["url"] as? String, let url = URL(string: urlString) {
            // Open URL in WebView
            NotificationCenter.default.post(name: NSNotification.Name("OpenURL"), object: url)
        }

        completionHandler()
    }

    // MARK: - MessagingDelegate

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "")")

        // Subscribe to topics
        Messaging.messaging().subscribe(toTopic: "live_stream") { error in
            if let error = error {
                print("Error subscribing to live_stream: \(error)")
            } else {
                print("Subscribed to live_stream topic")
            }
        }

        Messaging.messaging().subscribe(toTopic: "announcements") { error in
            if let error = error {
                print("Error subscribing to announcements: \(error)")
            } else {
                print("Subscribed to announcements topic")
            }
        }
    }
}
