//
//  TimerView.swift
//  TM.io
//
//  Created by Tazi Grigolia on 10/21/24.
//


import SwiftUI
import UserNotifications
import AudioToolbox
import Charts

struct TimerView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    @AppStorage("totalMeditationTime") private var totalMeditationTime: TimeInterval = 0
    @State private var timerDuration: Double
    @State private var isTimerRunning = false
    @State private var remainingTime: Double
    @State private var sessionCount: Int
    @State private var showCompletionAlert = false
    @State private var isEditingTime = false
    @State private var showHeartRateGraph = false
    @State private var showingStreaksView = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let availableDurations = [1, 10, 15, 20] // Available durations in minutes
    
    init() {
        let savedDuration = UserDefaults.standard.double(forKey: "timerDuration")
        let initialDuration = savedDuration > 0 ? savedDuration : 20.0 * 60
        _timerDuration = State(initialValue: initialDuration)
        _remainingTime = State(initialValue: initialDuration)
        _sessionCount = State(initialValue: UserDefaults.standard.integer(forKey: "dailySessionCount"))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        streakDisplay
                    }
                    .padding(.horizontal)
                    
                    Text("Relax Your Mind and Body")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Timer circle view
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.3)
                            .foregroundColor(.yellow)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(1 - (remainingTime / timerDuration)))
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.yellow)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.linear, value: remainingTime)
                        
                        VStack {
                            if isEditingTime {
                                Picker("Duration", selection: $timerDuration) {
                                    ForEach(availableDurations, id: \.self) { duration in
                                        Text("\(duration) min").tag(Double(duration * 60))
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 100, height: 100)
                                .clipped()
                            } else {
                                Text(timeString(from: Int(remainingTime)))
                                    .font(.system(size: 40, weight: .bold))
                                Text("TM")
                                    .font(.system(size: 24, weight: .semibold))
                            }
                        }
                        .onTapGesture {
                            if !isTimerRunning {
                                isEditingTime.toggle()
                            }
                        }
                    }
                    .frame(width: 250, height: 250)
                    
                    Button(action: toggleTimer) {
                        Text(isTimerRunning ? "Pause" : "Start")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.yellow)
                            .cornerRadius(25)
                    }
                    .padding()
                    .disabled(isEditingTime)
                    
                    Text("Session \(sessionCount)/2 today")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    if isTimerRunning || showHeartRateGraph {
                        VStack {
                            Text("Current Heart Rate: \(Int(healthKitManager.currentHeartRate)) BPM")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HeartRateGraph(data: healthKitManager.heartRatePoints)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 100) // Add extra padding at the bottom
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingStreaksView) {
            StreaksView()
        }
        .onReceive(timer) { _ in
            if isTimerRunning && remainingTime > 0 {
                remainingTime -= 1
            } else if isTimerRunning && remainingTime == 0 {
                completeTimer()
            }
        }
        .onChange(of: timerDuration) { newValue in
            if !isTimerRunning {
                remainingTime = newValue
                UserDefaults.standard.set(newValue, forKey: "timerDuration")
            }
        }
        .onAppear {
            healthKitManager.setupHealthKit()
            resetSessionCountIfNeeded()
            #if targetEnvironment(simulator)
            showHeartRateGraph = true
            #endif
        }
        .alert(isPresented: $showCompletionAlert) {
            Alert(
                title: Text("Meditation Complete"),
                message: Text("Good job on your meditation!"),
                dismissButton: .default(Text("OK")) {
                    resetTimer()
                }
            )
        }
    }
    
    private var streakDisplay: some View {
        Button(action: {
            showingStreaksView = true
        }) {
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.yellow)
                Text("\(currentStreak)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
            }
            .padding(8)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(15)
        }
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
        
        // Update total meditation time
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
        // Vibrate the device
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        // Schedule a local notification
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

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
