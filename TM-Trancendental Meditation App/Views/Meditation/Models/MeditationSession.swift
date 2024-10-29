//
//  MeditationSession.swift
//  TM-Trancendental Meditation App
//
//  Created by Tazi Grigolia on 10/23/24.
//

import Foundation

struct MeditationSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let averageHeartRate: Double
    let heartRateData: [HeartRateDataPoint]
    
    struct HeartRateDataPoint: Codable {
        let timestamp: Date
        let value: Double
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, duration, averageHeartRate, heartRateData
    }
    
    init(id: UUID = UUID(), date: Date, duration: TimeInterval, averageHeartRate: Double, heartRateData: [(Date, Double)]) {
        self.id = id
        self.date = date
        self.duration = duration
        self.averageHeartRate = averageHeartRate
        self.heartRateData = heartRateData.map { HeartRateDataPoint(timestamp: $0.0, value: $0.1) }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        averageHeartRate = try container.decode(Double.self, forKey: .averageHeartRate)
        heartRateData = try container.decode([HeartRateDataPoint].self, forKey: .heartRateData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(duration, forKey: .duration)
        try container.encode(averageHeartRate, forKey: .averageHeartRate)
        try container.encode(heartRateData, forKey: .heartRateData)
    }
}
