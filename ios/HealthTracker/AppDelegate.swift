import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationService.shared
        
        // Configure notification appearance
        configureNotificationAppearance()
        
        return true
    }
    
    private func configureNotificationAppearance() {
        // Request notification permission on first launch if needed
        let notificationService = NotificationService.shared
        notificationService.checkNotificationStatus()
    }
    
    // Note: UILocalNotification is deprecated. We use UserNotifications framework instead.
    
    // Handle remote notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Handle remote notification registration if needed in future
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}