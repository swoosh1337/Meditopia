import SwiftUI
import UserNotifications
import AudioToolbox

class TimerViewModel: ObservableObject {
    @Published var timerDuration: Double
    @Published var isTimerRunning = false
    @Published var remainingTime: Double
    @Published var sessionCount: Int
    @Published var showCompletionAlert = false
    @Published var isEditingTime = false
    @Published var showHeartRateGraph = false
    @Published var showingStreaksView = false
    
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    @AppStorage("totalMeditationTime") private var totalMeditationTime: TimeInterval = 0
    
    let healthKitManager: HealthKitManager
    let availableDurations = [1, 10, 15, 20] // Available durations in minutes
    
    init(healthKitManager: HealthKitManager = HealthKitManager()) {
        self.healthKitManager = healthKitManager
        let savedDuration = UserDefaults.standard.double(forKey: "timerDuration")
        let initialDuration = savedDuration > 0 ? savedDuration : 20.0 * 60
        self.timerDuration = initialDuration
        self.remainingTime = initialDuration
        self.sessionCount = UserDefaults.standard.integer(forKey: "dailySessionCount")
    }
    
    func toggleTimer() {
        if !isTimerRunning {
            remainingTime = timerDuration
            healthKitManager.startHeartRateMonitoring()
            showHeartRateGraph = true
        } else {
            healthKitManager.stopHeartRateMonitoring()
        }
        isTimerRunning.toggle()
        isEditingTime = false
    }
    
    func completeTimer() {
        isTimerRunning = false
        healthKitManager.stopHeartRateMonitoring()
        sendNotification()
        incrementSessionCount()
        StreakManager.updateStreaks()
        
        totalMeditationTime += timerDuration
        
        showCompletionAlert = true
        showHeartRateGraph = true
    }
    
    func resetTimer() {
        isTimerRunning = false
        remainingTime = timerDuration
        isEditingTime = false
    }
    
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    func sendNotification() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        let content = UNMutableNotificationContent()
        content.title = "Meditation Complete"
        content.body = "Great job! You've finished your meditation session."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func incrementSessionCount() {
        sessionCount += 1
        if sessionCount > 2 {
            sessionCount = 2
        }
        UserDefaults.standard.set(sessionCount, forKey: "dailySessionCount")
    }
    
    func resetSessionCountIfNeeded() {
        let calendar = Calendar.current
        let lastResetDate = UserDefaults.standard.object(forKey: "lastResetDate") as? Date ?? Date.distantPast
        
        if !calendar.isDateInToday(lastResetDate) {
            sessionCount = 0
            UserDefaults.standard.set(sessionCount, forKey: "dailySessionCount")
            UserDefaults.standard.set(Date(), forKey: "lastResetDate")
        }
    }
}
