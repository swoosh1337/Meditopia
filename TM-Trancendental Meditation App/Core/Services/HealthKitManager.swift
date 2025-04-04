import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private let backgroundQueue = DispatchQueue(label: "com.tm.healthkit.background", qos: .userInitiated)
    private var heartRateQuery: HKQuery?
    
    @Published var currentHeartRate: Double = 0
    @Published var heartRatePoints: [(Date, Double)] = []
    @Published var isMonitoringHeartRate: Bool = false
    @Published var isUpdatingHeartRate: Bool = false
    @Published var lastHeartRateUpdate: Date?
    
    private var hasInitialHeartRate: Bool = false
    
    // MARK: - Setup
    
    func setupHealthKit() {
        // Check if HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        // Define the heart rate type we want to read
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("Heart Rate Type is no longer available in HealthKit")
            return
        }
        
        // Request authorization to read heart rate data
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if let error = error {
                print("HealthKit authorization error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .heartRateMonitoringFailed, object: nil)
                }
                return
            }
            
            if !success {
                print("HealthKit authorization was not successful")
                // Notify observers that monitoring failed
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .heartRateMonitoringFailed, object: nil)
                }
            }
        }
    }
    
    // MARK: - Heart Rate Monitoring
    
    func startHeartRateMonitoring() {
        DispatchQueue.main.async {
            self.isMonitoringHeartRate = true
            self.isUpdatingHeartRate = true
        }
        
        // Clear previous data
        heartRatePoints.removeAll()
        hasInitialHeartRate = false
        
        // Debug log
        print("HealthKitManager: Starting heart rate monitoring")
        
        #if targetEnvironment(simulator)
        // Use simulated data in the simulator
        simulateHeartRateMonitoring()
        return
        #endif
        
        // Preload the most recent heart rate first
        preloadLatestHeartRate { [weak self] success in
            guard let self = self else { return }
            
            if !success {
                print("HealthKitManager: Failed to load initial heart rate")
                
                // Only add a placeholder if we couldn't get real data
                if self.heartRatePoints.isEmpty {
                    DispatchQueue.main.async {
                        // Mark placeholder data distinctively so UI can show it's not real data
                        self.currentHeartRate = 0
                        self.hasInitialHeartRate = false
                        
                        // Notify that monitoring may have issues
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            // If after 5 seconds we still have no data, notify of an issue
                            if self.heartRatePoints.isEmpty || self.currentHeartRate == 0 {
                                print("HealthKitManager: No heart rate data after 5 seconds")
                                NotificationCenter.default.post(name: .heartRateMonitoringFailed, object: nil)
                            }
                        }
                    }
                }
            } else {
                print("HealthKitManager: Successfully loaded initial heart rate: \(self.currentHeartRate) BPM")
            }
            
            // Start the heart rate monitoring query on background thread
            self.backgroundQueue.async {
                self.setupHeartRateQuery()
            }
        }
    }
    
    func stopHeartRateMonitoring() {
        print("HealthKitManager: Stopping heart rate monitoring")
        
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
        
        DispatchQueue.main.async {
            self.isMonitoringHeartRate = false
            self.isUpdatingHeartRate = false
        }
    }
    
    // Force an immediate fetch of the heart rate - useful when app returns from background
    func forceFetchHeartRate() {
        if isMonitoringHeartRate {
            DispatchQueue.main.async {
                self.isUpdatingHeartRate = true
            }
            
            backgroundQueue.async { [weak self] in
                self?.fetchLatestHeartRate { _ in
                    DispatchQueue.main.async {
                        self?.isUpdatingHeartRate = false
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func preloadLatestHeartRate(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            self.isUpdatingHeartRate = true
        }
        
        backgroundQueue.async { [weak self] in
            self?.fetchLatestHeartRate { success in
                DispatchQueue.main.async {
                    self?.isUpdatingHeartRate = false
                }
                completion(success)
            }
        }
    }
    
    private func fetchLatestHeartRate(completion: @escaping (Bool) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("HealthKitManager: Heart rate type is not available")
            completion(false)
            return
        }
        
        // Create a predicate to get data from the last 5 minutes
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-5 * 60)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        // Sort by date to get the most recent sample first
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // Define the limit to 1 to get just the most recent sample
        let limit = 5
        
        // Create a query to fetch the most recent heart rate sample
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, error in
            guard let self = self else { return }
            
            if let error = error {
                print("HealthKitManager: Error fetching latest heart rate: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let samples = samples, !samples.isEmpty, let sample = samples.first as? HKQuantitySample else {
                print("HealthKitManager: No heart rate samples available")
                completion(false)
                return
            }
            
            print("HealthKitManager: Retrieved \(samples.count) heart rate samples")
            
            let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            
            // Log all samples to help debug
            for (index, potentialSample) in samples.enumerated() {
                if let hrSample = potentialSample as? HKQuantitySample {
                    let hr = hrSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    let timeAgo = Int(Date().timeIntervalSince(hrSample.endDate))
                    print("HealthKitManager: Sample \(index+1) - \(hr) BPM (\(timeAgo) seconds ago)")
                }
            }
            
            DispatchQueue.main.async {
                self.currentHeartRate = heartRate
                self.heartRatePoints.append((sample.endDate, heartRate))
                self.lastHeartRateUpdate = Date()
                self.hasInitialHeartRate = true
            }
            
            completion(true)
        }
        
        healthStore.execute(query)
    }
    
    private func setupHeartRateQuery() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("Heart rate type is not available")
            return
        }
        
        // Stop any existing queries
        if let query = heartRateQuery {
            healthStore.stop(query)
        }
        
        // Create a predicate to get real-time updates
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
        
        // Create a long-running query to receive heart rate updates
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit) { [weak self] (_, samples, _, _, error) in
                if let error = error {
                    print("Heart rate query error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .heartRateMonitoringFailed, object: nil)
                    }
                    return
                }
                
                self?.processHeartRateSamples(samples)
            }
        
        // Set up an observer query to get real-time updates
        let observerQuery = HKObserverQuery(sampleType: heartRateType, predicate: predicate) { [weak self] (query, completionHandler, error) in
            if let error = error {
                print("Heart rate observer query error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            
            // Fetch the latest heart rate samples
            self?.fetchLatestHeartRate { _ in
                completionHandler()
            }
        }
        
        // Enable background delivery for the heart rate type
        let backgroundDeliveryFrequency: HKUpdateFrequency = .immediate
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: backgroundDeliveryFrequency) { success, error in
            if success {
                print("Background delivery enabled for heart rate")
            } else if let error = error {
                print("Failed to enable background delivery: \(error.localizedDescription)")
            }
        }
        
        // Execute both queries
        healthStore.execute(query)
        healthStore.execute(observerQuery)
        
        // Store reference to the main query
        heartRateQuery = query
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        // Process on background thread
        backgroundQueue.async { [weak self] in
            guard let self = self, let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                return
            }
            
            DispatchQueue.main.async {
                self.isUpdatingHeartRate = true
            }
            
            // Process samples
            var newPoints: [(Date, Double)] = []
            
            for sample in samples {
                let heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                newPoints.append((sample.endDate, heartRate))
            }
            
            // Update on main thread
            DispatchQueue.main.async {
                // Update the current heart rate with the most recent value
                if let lastPoint = newPoints.last {
                    self.currentHeartRate = lastPoint.1
                }
                
                // Add the new points
                self.heartRatePoints.append(contentsOf: newPoints)
                
                // Limit the number of points to keep performance good
                let maxPoints = 120 // About 10 minutes of data
                if self.heartRatePoints.count > maxPoints {
                    self.heartRatePoints = Array(self.heartRatePoints.suffix(maxPoints))
                }
                
                // Sort points by date to ensure correct graph display
                self.heartRatePoints.sort(by: { $0.0 < $1.0 })
                
                // Update the last heart rate update timestamp
                self.lastHeartRateUpdate = Date()
                self.isUpdatingHeartRate = false
            }
        }
    }
    
    // MARK: - Simulator Support
    
    #if targetEnvironment(simulator)
    private func simulateHeartRateMonitoring() {
        // For simulator testing, generate fake heart rate data
        DispatchQueue.main.async {
            self.isMonitoringHeartRate = true
            
            // Start with reasonable heart rate
            self.currentHeartRate = 70.0
            
            // Create 30 seconds of past data
            var fakeData: [(Date, Double)] = []
            for i in 0..<30 {
                let time = Date().addingTimeInterval(Double(-30 + i))
                let rate = 70.0 + Double.random(in: -5...5)
                fakeData.append((time, rate))
            }
            
            self.heartRatePoints = fakeData
            
            // Set up a timer to periodically update with fake data
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
                guard let self = self, self.isMonitoringHeartRate else {
                    timer.invalidate()
                    return
                }
                
                // Generate new heart rate value with slight variation from previous
                let newRate = max(60, min(100, self.currentHeartRate + Double.random(in: -2...2)))
                self.currentHeartRate = newRate
                
                // Add to heart rate points
                self.heartRatePoints.append((Date(), newRate))
                
                // Keep only the last 120 points
                if self.heartRatePoints.count > 120 {
                    self.heartRatePoints.removeFirst()
                }
                
                self.lastHeartRateUpdate = Date()
            }
        }
    }
    #endif
}
