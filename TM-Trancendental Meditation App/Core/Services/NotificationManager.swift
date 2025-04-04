import Foundation
import UserNotifications
import AudioToolbox
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private var hasRequestedPermission = false
    
    func setupNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermissions()
            case .denied:
                print("Notification permissions denied, reminders won't work")
            case .authorized, .provisional, .ephemeral:
                print("Notification permissions granted")
            @unknown default:
                break
            }
        }
    }
    
    private func requestPermissions() {
        if !hasRequestedPermission {
            hasRequestedPermission = true
            
            let options: UNAuthorizationOptions = [.alert, .sound, .badge, .criticalAlert]
            
            UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
                if success {
                    print("Notification permissions granted")
                    
                    // Ensure we can receive notifications in the foreground too
                    #if os(iOS)
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    #endif
                } else if let error = error {
                    print("Error requesting notification permissions: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func sendMeditationCompleteNotification() {
        // Strong, prolonged haptic feedback
        self.generateStrongHapticFeedback()
        
        // Send notification to Apple Watch if installed
        WatchConnectivityManager.shared.sendMeditationCompletedMessage()
        
        // Create notification with sound
        let content = UNMutableNotificationContent()
        content.title = "Meditation Complete"
        content.body = "Great job! You've finished your meditation session."
        content.sound = UNNotificationSound.defaultCritical
        
        // Make it a critical notification that can break through Do Not Disturb
        content.categoryIdentifier = "meditation.complete"
        
        // Add a custom sound that's longer/more noticeable if needed
        // content.sound = UNNotificationSound(named: UNNotificationSoundName("meditation_complete.wav"))
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "meditation-complete-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
        
        // Schedule a second notification after a brief delay as a backup
        self.scheduleBackupNotification()
    }
    
    private func scheduleBackupNotification() {
        // Create a backup notification that fires a few seconds later in case the first one is missed
        let content = UNMutableNotificationContent()
        content.title = "Meditation Session Ended"
        content.body = "Don't forget to check your results!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "meditation-complete-backup-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling backup notification: \(error)")
            }
        }
    }
    
    private func generateStrongHapticFeedback() {
        // Play system sound with vibration
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        // Delay slightly and vibrate again for stronger effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            #if os(iOS)
            // For devices with haptic feedback, add another layer
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
            #endif
            
            // Add one more vibration after a brief pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                
                // Try to play a longer vibration pattern if available
                AudioServicesPlaySystemSound(1521) // Strong vibration
            }
        }
    }
    
    // Method to register category for Apple Watch forwarding
    func registerNotificationCategories() {
        // Create category for meditation completion notifications
        // Using options that are not deprecated in iOS 15+
        #if compiler(>=5.5) && canImport(Darwin) && !targetEnvironment(macCatalyst)
        // For iOS 15 and later
        if #available(iOS 15.0, *) {
            let completeCategory = UNNotificationCategory(
                identifier: "meditation.complete",
                actions: [],
                intentIdentifiers: [],
                options: [.customDismissAction]
            )
            UNUserNotificationCenter.current().setNotificationCategories([completeCategory])
        } else {
            // For iOS 14 and earlier
            let completeCategory = UNNotificationCategory(
                identifier: "meditation.complete",
                actions: [],
                intentIdentifiers: [],
                options: [.allowAnnouncement]
            )
            UNUserNotificationCenter.current().setNotificationCategories([completeCategory])
        }
        #else
        // Fallback for other platforms
        let completeCategory = UNNotificationCategory(
            identifier: "meditation.complete",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([completeCategory])
        #endif
    }
} 