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
import AVFoundation
import UIKit
import Combine

// Use the existing TimerViewModel from ViewModels folder
struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    
    // Add a state property to hold cancellables rather than a stored property
    // This solves the "Cannot pass immutable value as inout argument" errors
    @State private var cancellables = Set<AnyCancellable>()
    
    // Timer that updates every 0.5 seconds for a smooth countdown
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
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
                            .foregroundColor(Configuration.primaryColor)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(1 - (viewModel.remainingTime / viewModel.timerDuration)))
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .foregroundColor(Configuration.primaryColor)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.linear, value: viewModel.remainingTime)
                        
                        VStack {
                            if viewModel.isEditingTime {
                                ZStack {
                                    // Background circle
                                    Circle()
                                        .stroke(Configuration.primaryColor.opacity(0.1), lineWidth: 2)
                                        .frame(width: 200, height: 200)
                                    
                                    // Center text
                                    Text("Select\nDuration")
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    // Time selection buttons
                                    ForEach(viewModel.availableDurations.indices, id: \.self) { index in
                                        let angle = Double(index) * (360.0 / Double(viewModel.availableDurations.count))
                                        let duration = viewModel.availableDurations[index]
                                        
                                        Button(action: {
                                            setDuration(duration)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(getSelectedMinutes() == duration ? Configuration.primaryColor : Configuration.primaryColor.opacity(0.2))
                                                    .frame(width: 60, height: 60)
                                                
                                                VStack(spacing: 2) {
                                                    Text("\(duration)")
                                                        .font(.system(size: 20, weight: .bold))
                                                    Text("min")
                                                        .font(.system(size: 10))
                                                }
                                                .foregroundColor(getSelectedMinutes() == duration ? .white : Configuration.primaryColor)
                                            }
                                        }
                                        .offset(
                                            x: 75 * cos(angle * .pi / 180),
                                            y: 75 * sin(angle * .pi / 180)
                                        )
                                    }
                                }
                            } else {
                                Text(viewModel.timeString(from: Int(viewModel.remainingTime)))
                                    .font(.system(size: 40, weight: .bold))
                            }
                        }
                        .onTapGesture {
                            if !viewModel.isTimerRunning {
                                viewModel.isEditingTime.toggle()
                            }
                        }
                    }
                    .frame(width: 250, height: 250)
                    
                    Button(action: {
                        toggleTimerAction()
                    }) {
                        Text(viewModel.isTimerRunning ? "Pause" : "Start")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(
                                isLoading && !viewModel.isTimerRunning 
                                ? Configuration.primaryColor.opacity(0.6)
                                : Configuration.primaryColor
                            )
                            .cornerRadius(25)
                            .overlay(
                                Group {
                                    if isLoading && !viewModel.isTimerRunning {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                }
                            )
                    }
                    .padding()
                    .disabled(viewModel.isEditingTime || (isLoading && !viewModel.isTimerRunning))
                    
                    Text("Session \(viewModel.sessionCount)/2 today")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    if viewModel.isTimerRunning || viewModel.showHeartRateGraph {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Configuration.primaryColor)
                                    .font(.headline)
                                
                                if viewModel.healthKitManager.currentHeartRate > 0 {
                                    Text("\(Int(viewModel.healthKitManager.currentHeartRate)) BPM")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("Waiting for heart rate data...")
                                        .font(.headline)
                                        .foregroundColor(Configuration.secondaryTextColor)
                                }
                                
                                Spacer()
                                
                                if viewModel.isTimerRunning && isUpdatingHeartRate {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Configuration.primaryColor))
                                        .scaleEffect(0.7)
                                }
                            }
                            
                            if heartRateStatus != .available && !isUpdatingHeartRate {
                                HStack {
                                    Text(heartRateStatusMessage)
                                        .font(.caption)
                                        .foregroundColor(Configuration.secondaryTextColor)
                                    
                                    Spacer()
                                    
                                    if heartRateStatus == .unavailable {
                                        Button(action: {
                                            retryHeartRateMonitoring()
                                        }) {
                                            Text("Try Again")
                                                .font(.caption)
                                                .foregroundColor(Configuration.primaryColor)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Configuration.primaryColor.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            
                            HeartRateGraph(data: viewModel.healthKitManager.heartRatePoints)
                                .onTapGesture {
                                    showExpandedHeartRate = true
                                }
                                .animation(.easeInOut, value: viewModel.healthKitManager.heartRatePoints.count)
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
        // Timer updates
        .onReceive(timer) { _ in
            handleTimerTick()
        }
        .onChange(of: viewModel.timerDuration) { _, newValue in
            updateTimerDuration(newValue)
        }
        .onAppear {
            setupApp()
        }
        .onDisappear {
            handleDisappear()
        }
        // Background/foreground notifications
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            handleEnterBackground()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            handleEnterForeground()
        }
        // Alerts and sheets
        .alert(isPresented: $viewModel.showCompletionAlert) {
            Alert(
                title: Text("Meditation Complete"),
                message: Text("Good job on your meditation!"),
                dismissButton: .default(Text("OK")) {
                    viewModel.resetTimer()
                }
            )
        }
        .alert("Would you like to journal about your meditation?", isPresented: $showJournalPrompt) {
            Button("Yes") {
                showNewJournalEntry = true
            }
            Button("No", role: .cancel) {
                viewModel.resetTimer()
            }
        }
        .sheet(isPresented: $showNewJournalEntry) {
            NewJournalEntryView(meditationDuration: viewModel.timerDuration)
        }
        .fullScreenCover(isPresented: $showExpandedHeartRate) {
            NavigationView {
                ZStack {
                    Configuration.backgroundColor
                        .ignoresSafeArea()
                    
                    ScrollView {
                        HeartRateGraph(
                            data: viewModel.healthKitManager.heartRatePoints,
                            isExpanded: true,
                            onDismiss: { showExpandedHeartRate = false }
                        )
                        .padding()
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .alert("Your Trial is Ending Soon", isPresented: $showTrialEndingAlert) {
            Button("Upgrade Now") {
                showPaywall = true
            }
            .foregroundColor(.blue)
            
            Button("Continue", role: .cancel) {}
        } message: {
            if let endDate = purchaseManager.trialEndDate, purchaseManager.isTrialActive {
                let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
                Text("You have \(daysLeft) day\(daysLeft == 1 ? "" : "s") left in your trial. Upgrade now to continue your meditation journey without interruption.")
            } else {
                Text("Your trial period is ending soon. Upgrade now to continue your meditation journey without interruption.")
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(allowDismissal: true)
        }
    }
    
    // MARK: - State Properties
    @State private var showJournalPrompt = false
    @State private var showNewJournalEntry = false
    @State private var showExpandedHeartRate = false
    @State private var isLoading = false
    @State private var isUpdatingHeartRate = false
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var heartRateStatus: HeartRateStatus = .unknown
    @State private var showTrialEndingAlert = false
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    
    enum HeartRateStatus {
        case unknown
        case available
        case noPermission
        case unavailable
    }
    
    private var heartRateStatusMessage: String {
        switch heartRateStatus {
        case .unknown:
            return "Initializing heart rate monitor..."
        case .available:
            return ""
        case .noPermission:
            return "Heart rate monitoring requires Health permission"
        case .unavailable:
            return "Unable to access heart rate data"
        }
    }
    
    // MARK: - UI Components
    
    private var streakDisplay: some View {
        Button(action: {
            viewModel.showingStreaksView = true
        }) {
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .foregroundColor(Configuration.primaryColor)
                // Use UserDefaults directly since currentStreak is private in ViewModel
                Text("\(UserDefaults.standard.integer(forKey: "currentStreak"))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Configuration.primaryColor)
            }
            .padding(8)
            .background(Configuration.primaryColor.opacity(0.1))
            .cornerRadius(15)
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupApp() {
        // The ViewModel already loads stored duration in its initializer
        // No need to call a separate method
        
        // Setup health kit
        viewModel.healthKitManager.setupHealthKit()
        
        // Setup notifications
        NotificationManager.shared.setupNotifications()
        NotificationManager.shared.registerNotificationCategories()
        
        viewModel.resetSessionCountIfNeeded()
        StreakManager.checkAndResetStreak()
        
        // Subscribe to heart rate updates
        setupHeartRateObservers()
        
        // Resume meditation if in progress
        resumeMeditationIfNeeded()
        
        #if targetEnvironment(simulator)
        viewModel.showHeartRateGraph = true
        #endif
        
        // Check trial status
        checkTrialStatus()
    }
    
    private func setupHeartRateObservers() {
        // Set up publisher for heart rate monitoring status
        viewModel.healthKitManager.$isMonitoringHeartRate
            .receive(on: DispatchQueue.main)
            .sink { isMonitoring in
                self.viewModel.showHeartRateGraph = isMonitoring
                if isMonitoring {
                    // When monitoring starts, we don't know the status yet
                    self.heartRateStatus = .unknown
                }
            }
            .store(in: &cancellables)
        
        // Set up publisher for heart rate updates
        viewModel.healthKitManager.$isUpdatingHeartRate
            .receive(on: DispatchQueue.main)
            .sink { isUpdating in
                withAnimation {
                    if !self.viewModel.isTimerRunning {
                        self.isLoading = isUpdating
                    }
                    self.isUpdatingHeartRate = isUpdating
                }
            }
            .store(in: &cancellables)
            
        // Check when we get heart rate data
        viewModel.healthKitManager.$heartRatePoints
            .receive(on: DispatchQueue.main)
            .sink { points in
                if !points.isEmpty && points.last?.1 ?? 0 > 0 {
                    // We have real heart rate data
                    self.heartRateStatus = .available
                } else if self.viewModel.isTimerRunning && !self.isUpdatingHeartRate && points.isEmpty {
                    // We've tried to get data but have none
                    self.heartRateStatus = .unavailable
                }
            }
            .store(in: &cancellables)
        
        // Set up publisher for monitoring failures
        NotificationCenter.default.publisher(for: .heartRateMonitoringFailed)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.isLoading = false
                self.heartRateStatus = .noPermission
                if self.viewModel.isTimerRunning {
                    // Show error only if timer is running
                    self.showHeartRateMonitoringError()
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleDisappear() {
        if viewModel.isTimerRunning {
            // Store end time in UserDefaults to persist across app launches
            if let endTime = endTime {
                UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "meditationEndTime")
            }
        }
        
        // Cancel subscriptions - no need to modify self.cancellables
        cancellables.removeAll()
    }
    
    private func handleTimerTick() {
        guard viewModel.isTimerRunning, let endTime = endTime else { return }
        
        if Date() >= endTime {
            completeTimer()
        } else {
            viewModel.remainingTime = endTime.timeIntervalSince(Date())
        }
    }
    
    private func updateTimerDuration(_ newValue: Double) {
        if !viewModel.isTimerRunning {
            viewModel.remainingTime = newValue
            UserDefaults.standard.set(newValue, forKey: "timerDuration")
        }
    }
    
    private func setDuration(_ minutes: Int) {
        viewModel.timerDuration = Double(minutes * 60)
        viewModel.remainingTime = viewModel.timerDuration
        viewModel.isEditingTime = false
    }
    
    private func getSelectedMinutes() -> Int {
        return Int(viewModel.timerDuration / 60)
    }
    
    private func toggleTimerAction() {
        // Toggle the viewModel state first
        viewModel.toggleTimer()
        
        if viewModel.isTimerRunning {
            // Only if we're starting the timer, not pausing
            // Set start and end times
            startTime = Date()
            endTime = Date().addingTimeInterval(viewModel.remainingTime)
            
            // Prevent screen from dimming
            setIdleTimerDisabled(true)
            
            // Start background support
            BackgroundTaskManager.startBackgroundSupport()
        } else {
            // If pausing, update the remaining time value
            if let endTime = endTime {
                viewModel.remainingTime = endTime.timeIntervalSince(Date())
            }
            
            // Allow screen to dim when paused
            setIdleTimerDisabled(false)
            
            // No need for background mode if paused
            BackgroundTaskManager.stopBackgroundSupport()
        }
    }
    
    private func resumeMeditationIfNeeded() {
        if let savedEndTimeInterval = UserDefaults.standard.object(forKey: "meditationEndTime") as? TimeInterval {
            let savedEndTime = Date(timeIntervalSince1970: savedEndTimeInterval)
            
            // Check if the end time is in the future
            if savedEndTime > Date() {
                // Resume meditation
                startTime = Date()
                endTime = savedEndTime
                viewModel.remainingTime = savedEndTime.timeIntervalSince(Date())
                viewModel.isTimerRunning = true
                
                // Start background support first
                BackgroundTaskManager.startBackgroundSupport()
                
                // Start heart rate monitoring with a slight delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.healthKitManager.startHeartRateMonitoring()
                    viewModel.showHeartRateGraph = true
                }
            } else {
                // The meditation should have completed while the app was closed
                if savedEndTime > Date().addingTimeInterval(-3600) { // Within the last hour
                    // Complete the meditation
                    completeTimer()
                } else {
                    // Clear the stored end time if it's too old
                    UserDefaults.standard.removeObject(forKey: "meditationEndTime")
                }
            }
        }
    }
    
    private func handleEnterBackground() {
        if viewModel.isTimerRunning {
            // Activate background mode support
            BackgroundTaskManager.startBackgroundSupport()
            
            // Store the current end time in case the app is terminated
            if let endTime = endTime {
                UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "meditationEndTime")
            }
        }
    }
    
    private func handleEnterForeground() {
        if viewModel.isTimerRunning {
            // Stop background support when returning to foreground
            BackgroundTaskManager.stopBackgroundSupport()
            
            // Recalculate remaining time in case device time has changed
            if let endTime = endTime {
                viewModel.remainingTime = max(0, endTime.timeIntervalSince(Date()))
                
                // If the timer should have completed while in background
                if Date() >= endTime {
                    completeTimer()
                } else {
                    // Refresh heart rate data if it's been more than 15 seconds
                    if let lastUpdate = viewModel.healthKitManager.lastHeartRateUpdate,
                       Date().timeIntervalSince(lastUpdate) > 15 {
                        viewModel.healthKitManager.forceFetchHeartRate()
                    }
                }
            }
        }
    }
    
    private func showHeartRateMonitoringError() {
        let alert = UIAlertController(
            title: "Heart Rate Monitoring Issue",
            message: "Unable to access heart rate data. Please ensure Health permissions are granted or try again later.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Health Settings", style: .default) { _ in
            if let url = URL(string: "x-apple-health://") {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Continue Anyway", style: .cancel))
        
        // Present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    private func retryHeartRateMonitoring() {
        if viewModel.isTimerRunning {
            // Only try again if we're actively monitoring
            heartRateStatus = .unknown
            viewModel.healthKitManager.stopHeartRateMonitoring()
            
            // Small delay before restarting
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.healthKitManager.startHeartRateMonitoring()
            }
        }
    }
    
    private func completeTimer() {
        viewModel.isTimerRunning = false
        
        // Stop monitoring but don't hide the graph
        viewModel.healthKitManager.stopHeartRateMonitoring()
        BackgroundTaskManager.stopBackgroundSupport()
        
        // Allow screen dimming again
        setIdleTimerDisabled(false)
        
        // Clear stored end time
        UserDefaults.standard.removeObject(forKey: "meditationEndTime")
        startTime = nil
        endTime = nil
        
        // Send notification and update stats
        NotificationManager.shared.sendMeditationCompleteNotification()
        viewModel.incrementSessionCount()
        StreakManager.updateStreaks()
        
        // Update total meditation time directly with UserDefaults since it's private in ViewModel
        let currentTotal = UserDefaults.standard.double(forKey: "totalMeditationTime")
        UserDefaults.standard.set(currentTotal + viewModel.timerDuration, forKey: "totalMeditationTime")
        
        showJournalPrompt = true
    }
    
    // Prevent screen from dimming during meditation
    private func setIdleTimerDisabled(_ disabled: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = disabled
        }
    }
    
    // MARK: - View Lifecycle
    private func checkTrialStatus() {
        // If trial is active but ending within 1-2 days, show alert
        if let endDate = purchaseManager.trialEndDate, purchaseManager.isTrialActive {
            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
            if daysLeft <= 2 {
                showTrialEndingAlert = true
            }
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let heartRateMonitoringFailed = Notification.Name("heartRateMonitoringFailed")
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
