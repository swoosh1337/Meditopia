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
    @State private var showJournalPrompt = false
    @State private var showNewJournalEntry = false
    @State private var selectedMinutes: Int = 20  // Add this new state
    @State private var showExpandedHeartRate = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let availableDurations = [5, 10, 15, 20] // Available durations in minutes
    
    init() {
        let savedDuration = UserDefaults.standard.double(forKey: "timerDuration")
        let initialDuration = savedDuration > 0 ? savedDuration : 20.0 * 60
        _timerDuration = State(initialValue: initialDuration)
        _remainingTime = State(initialValue: initialDuration)
        _sessionCount = State(initialValue: UserDefaults.standard.integer(forKey: "dailySessionCount"))
        _selectedMinutes = State(initialValue: Int(initialDuration / 60))  // Add this
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
                                ZStack {
                                    // Background circle
                                    Circle()
                                        .stroke(Color.yellow.opacity(0.1), lineWidth: 2)
                                        .frame(width: 200, height: 200)  // Made smaller
                                    
                                    // Center text
                                    Text("Select\nDuration")
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    // Time selection buttons
                                    ForEach(availableDurations.indices, id: \.self) { index in
                                        let angle = Double(index) * (360.0 / Double(availableDurations.count))
                                        let duration = availableDurations[index]
                                        
                                        Button(action: {
                                            selectedMinutes = duration
                                            timerDuration = Double(duration * 60)
                                            remainingTime = timerDuration
                                            isEditingTime = false
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedMinutes == duration ? Color.yellow : Color.yellow.opacity(0.2))
                                                    .frame(width: 60, height: 60)  // Made smaller
                                                
                                                VStack(spacing: 2) {
                                                    Text("\(duration)")
                                                        .font(.system(size: 20, weight: .bold))  // Adjusted size
                                                    Text("min")
                                                        .font(.system(size: 10))  // Adjusted size
                                                }
                                                .foregroundColor(selectedMinutes == duration ? .white : .yellow)
                                            }
                                        }
                                        .offset(
                                            x: 75 * cos(angle * .pi / 180),  // Reduced offset
                                            y: 75 * sin(angle * .pi / 180)   // Reduced offset
                                        )
                                    }
                                }
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
                                .onTapGesture {
                                    showExpandedHeartRate = true
                                }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 100)
            }
            .background(Configuration.backgroundColor)
            .navigationBarHidden(true)
        }
        // .sheet(isPresented: $showingStreaksView) {
        //     StreaksView()
        // }
        .onReceive(timer) { _ in
            if isTimerRunning && remainingTime > 0 {
                remainingTime -= 1
                print("Timer tick. remainingTime: \(remainingTime)")
            } else if isTimerRunning && remainingTime == 0 {
                completeTimer()
            }
        }
        .onChange(of: timerDuration) { oldValue, newValue in
            if !isTimerRunning {
                remainingTime = newValue
                UserDefaults.standard.set(newValue, forKey: "timerDuration")
            }
        }
        .onAppear {
            healthKitManager.setupHealthKit()
            resetSessionCountIfNeeded()
            StreakManager.checkAndResetStreak()  
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
        .alert("Would you like to journal about your meditation?", isPresented: $showJournalPrompt) {
            Button("Yes") {
                showNewJournalEntry = true
            }
            Button("No", role: .cancel) {
                resetTimer()
            }
        }
        .sheet(isPresented: $showNewJournalEntry) {
            NewJournalEntryView(meditationDuration: timerDuration)
        }
        .fullScreenCover(isPresented: $showExpandedHeartRate) {
            NavigationView {
                ZStack {
                    Configuration.backgroundColor
                        .ignoresSafeArea()
                    
                    ScrollView {
                        HeartRateGraph(
                            data: healthKitManager.heartRatePoints,
                            isExpanded: true,
                            onDismiss: { showExpandedHeartRate = false }
                        )
                        .padding()
                    }
                }
                .navigationBarHidden(true)
            }
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
            healthKitManager.heartRatePoints.removeAll()
            remainingTime = timerDuration
            // Start monitoring with a delay to allow UI to update
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.healthKitManager.startHeartRateMonitoring()
                self.showHeartRateGraph = true
            }
        } else {
            healthKitManager.stopHeartRateMonitoring()
        }
        isTimerRunning.toggle()
        isEditingTime = false
    }
    
    func completeTimer() {
        isTimerRunning = false
        // Stop monitoring but don't hide the graph
        healthKitManager.stopHeartRateMonitoring()
        
        sendNotification()
        incrementSessionCount()
        StreakManager.updateStreaks()
        
        // Update total meditation time
        totalMeditationTime += timerDuration
        
        showJournalPrompt = true
    }
    
    func resetTimer() {
        isTimerRunning = false
        remainingTime = timerDuration
        isEditingTime = false
        // Don't reset the heart rate graph here
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
