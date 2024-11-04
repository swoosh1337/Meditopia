import SwiftUI
import Charts

struct HeartRateGraph: View {
    @Environment(\.colorScheme) private var colorScheme
    let data: [(Date, Double)]
    var isExpanded: Bool = false
    var onDismiss: (() -> Void)? = nil
    
    private var processedData: [(Date, Double)] {
        let pointsToShow = isExpanded ? data : Array(data.suffix(30))
        return pointsToShow
    }
    
    private var averageHeartRate: Double {
        let sum = processedData.reduce(0.0) { $0 + $1.1 }
        return processedData.isEmpty ? 0 : sum / Double(processedData.count)
    }
    
    private var maxHeartRate: Double {
        processedData.map { $0.1 }.max() ?? 0
    }
    
    private var minHeartRate: Double {
        processedData.map { $0.1 }.min() ?? 0
    }
    
    private var yAxisRange: ClosedRange<Double> {
        if processedData.isEmpty {
            return 40...120 // Default range when no data
        }
        
        let min = minHeartRate
        let max = maxHeartRate
        let buffer = (max - min) * 0.2 // Add 20% buffer
        
        return (min - buffer).rounded(.down)...(max + buffer).rounded(.up)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        if isExpanded {
            formatter.dateFormat = "HH:mm:ss"
        } else {
            formatter.dateFormat = "HH:mm"
        }
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: isExpanded ? 20 : 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Heart Rate")
                        .font(isExpanded ? .title : .headline)
                        .foregroundColor(Configuration.textColor)
                    
                    Text("BPM over time")
                        .font(isExpanded ? .title3 : .subheadline)
                        .foregroundColor(Configuration.secondaryTextColor)
                }
                
                Spacer()
                
                if isExpanded {
                    Button(action: {
                        onDismiss?()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Configuration.secondaryTextColor)
                            .font(.title)
                    }
                    .padding()
                }
            }
            
            if isExpanded {
                HStack(spacing: 20) {
                    StatBox(title: "Average", value: Int(averageHeartRate))
                    StatBox(title: "Maximum", value: Int(maxHeartRate))
                    StatBox(title: "Minimum", value: Int(minHeartRate))
                }
            }
            
            Chart(processedData, id: \.0) { item in
                AreaMark(
                    x: .value("Time", item.0),
                    y: .value("Heart Rate", item.1)
                )
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [Color.yellow.opacity(0.5), Color.yellow.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                
                LineMark(
                    x: .value("Time", item.0),
                    y: .value("Heart Rate", item.1)
                )
                .foregroundStyle(Color.yellow)
                .lineStyle(StrokeStyle(lineWidth: isExpanded ? 3 : 2))
                
                if isExpanded {
                    PointMark(
                        x: .value("Time", item.0),
                        y: .value("Heart Rate", item.1)
                    )
                    .foregroundStyle(Color.yellow)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: isExpanded ? 30 : 60)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(formatTime(date))
                                .font(isExpanded ? .caption : .caption2)
                                .rotationEffect(.degrees(isExpanded ? -45 : 0))
                                .foregroundColor(Configuration.secondaryTextColor)
                        }
                        AxisTick()
                            .foregroundStyle(Configuration.secondaryTextColor)
                        AxisGridLine()
                            .foregroundStyle(Configuration.secondaryTextColor.opacity(0.2))
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        Text("\(value.as(Double.self)?.formatted() ?? "")")
                            .foregroundColor(Configuration.secondaryTextColor)
                    }
                    AxisTick()
                        .foregroundStyle(Configuration.secondaryTextColor)
                    AxisGridLine()
                        .foregroundStyle(Configuration.secondaryTextColor.opacity(0.2))
                }
            }
            .frame(height: isExpanded ? UIScreen.main.bounds.height * 0.4 : 200)
            .chartYScale(domain: yAxisRange)
        }
        .padding(isExpanded ? 20 : 16)
        .background(Configuration.backgroundColor)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct StatBox: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Configuration.secondaryTextColor)
            Text("\(value)")
                .font(.title2.bold())
                .foregroundColor(.yellow)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(10)
    }
}

struct HeartRateGraph_Previews: PreviewProvider {
    static func generateTestData(baseRate: Double, variance: Double = 5.0) -> [(Date, Double)] {
        var data: [(Date, Double)] = []
        let startTime = Date().addingTimeInterval(-600) // 10 minutes ago
        
        for i in 0..<60 {
            let time = startTime.addingTimeInterval(TimeInterval(i * 10))
            let randomVariance = Double.random(in: -variance...variance)
            let heartRate = baseRate + randomVariance
            data.append((time, heartRate))
        }
        return data
    }
    
    static var previews: some View {
        Group {
            // Normal heart rate (60-80 BPM)
            VStack {
                HeartRateGraph(data: generateTestData(baseRate: 70))
                    .padding()
                Text("Normal Heart Rate (60-80 BPM)")
                    .font(.caption)
            }
            .previewDisplayName("Normal Range")
            
            // Low heart rate (35-50 BPM)
            VStack {
                HeartRateGraph(data: generateTestData(baseRate: 42, variance: 7))
                    .padding()
                Text("Low Heart Rate (35-50 BPM)")
                    .font(.caption)
            }
            .previewDisplayName("Low Range")
            
            // High heart rate (120-160 BPM)
            VStack {
                HeartRateGraph(data: generateTestData(baseRate: 140, variance: 20))
                    .padding()
                Text("High Heart Rate (120-160 BPM)")
                    .font(.caption)
            }
            .previewDisplayName("High Range")
            
            // Expanded view with widely varying heart rates
            HeartRateGraph(
                data: generateTestData(baseRate: 100, variance: 40),
                isExpanded: true
            )
            .previewDisplayName("Expanded View (Varying Rates)")
        }
        .padding()
        .background(Configuration.backgroundColor)
    }
}
