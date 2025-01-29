import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var currentHeartRate: Double = 0
    @Published var heartRatePoints: [(Date, Double)] = []
    
    private var heartRateQuery: HKQuery?
    private let maxDataPoints = 60 // Store only last 60 readings
    
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    init() {
        if isSimulator {
            generateTestData()
        }
    }
    
    func setupHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if success {
                print("HealthKit authorization granted")
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    func startHeartRateMonitoring() {
        if isSimulator {
            simulateHeartRateMonitoring()
            return
        }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] (query, samples, deletedObjects, anchor, error) in
            guard let samples = samples as? [HKQuantitySample] else { return }
            self?.processHeartRateSamples(samples)
        }
        
        query.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) in
            guard let samples = samples as? [HKQuantitySample] else { return }
            self?.processHeartRateSamples(samples)
        }
        
        heartRateQuery = query
        healthStore.execute(query)
    }
    
    private func processHeartRateSamples(_ samples: [HKQuantitySample]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for sample in samples {
                let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                self.currentHeartRate = heartRate
                self.heartRatePoints.append((sample.startDate, heartRate))
                
                // Keep only the last maxDataPoints
                if self.heartRatePoints.count > self.maxDataPoints {
                    self.heartRatePoints.removeFirst(self.heartRatePoints.count - self.maxDataPoints)
                }
            }
        }
    }
    
    func stopHeartRateMonitoring() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
    }
    
    func clearData() {
        // method to explicitly clear data when needed
        heartRatePoints.removeAll()
        currentHeartRate = 0
    }
    
    private func generateTestData() {
        let now = Date()
        for i in 0..<maxDataPoints {
            let time = now.addingTimeInterval(Double(i * 10))
            let heartRate = Double.random(in: 60...80)
            heartRatePoints.append((time, heartRate))
        }
        currentHeartRate = heartRatePoints.last?.1 ?? 70
    }
    
    private func simulateHeartRateMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let newHeartRate = Double.random(in: 60...80)
            self.currentHeartRate = newHeartRate
            self.heartRatePoints.append((Date(), newHeartRate))
            
            // Keep only the last maxDataPoints
            if self.heartRatePoints.count > self.maxDataPoints {
                self.heartRatePoints.removeFirst(self.heartRatePoints.count - self.maxDataPoints)
            }
        }
    }
}
