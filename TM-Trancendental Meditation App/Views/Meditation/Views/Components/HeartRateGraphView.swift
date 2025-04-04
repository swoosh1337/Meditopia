import SwiftUI
import Charts

struct HeartRateGraph: View {
    @Environment(\.colorScheme) private var colorScheme
    let data: [(Date, Double)]
    var isExpanded: Bool = false
    var onDismiss: (() -> Void)? = nil
    
    // Memoize the processed data
    private var processedData: [(Date, Double)] {
        if data.isEmpty {
            return generatePlaceholderData()
        }
        
        // 1. Make a copy of the data
        var workingData = data
        
        // 2. Sort by date
        workingData.sort { $0.0 < $1.0 }
        
        // 3. Take only the needed points
        let pointsToShow = isExpanded ? workingData : Array(workingData.suffix(min(30, workingData.count)))
        
        // 4. Filter out zero or negative values which may be erroneous
        return pointsToShow.filter { $0.1 > 0 }
    }
    
    private func generatePlaceholderData() -> [(Date, Double)] {
        let now = Date()
        // Generate placeholder data when no actual data is available
        return (0..<10).map { i in
            (now.addingTimeInterval(Double(-10 + i) * 30), 70.0 + Double.random(in: -5...5))
        }
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
            return 60...80 // Default range when no data
        }
        
        let min = max(40, minHeartRate - 5) // Ensure minimum is at least 40
        let max = maxHeartRate + 5 // Add some padding
        
        // Ensure there's always a reasonable range even with flat data
        if max - min < 10 {
            return (min - 5)...(max + 5)
        }
        
        return min...max
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
    
    private var chartData: [HeartRateDataPoint] {
        processedData.enumerated().map { index, item in
            HeartRateDataPoint(id: index, time: item.0, rate: item.1)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: isExpanded ? 20 : 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Heart Rate")
                        .font(isExpanded ? .title2.bold() : .headline)
                        .foregroundColor(Configuration.primaryColor)
                    
                    Text("BPM over time")
                        .font(isExpanded ? .subheadline : .caption)
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
                HStack(spacing: 15) {
                    StatBox(title: "Average", value: Int(averageHeartRate), icon: "heart.text.square")
                    StatBox(title: "Maximum", value: Int(maxHeartRate), icon: "arrow.up.heart")
                    StatBox(title: "Minimum", value: Int(minHeartRate), icon: "arrow.down.heart")
                }
            }
            
            Chart(chartData) { item in
                AreaMark(
                    x: .value("Time", item.time),
                    y: .value("Heart Rate", item.rate)
                )
                .interpolationMethod(.catmullRom) // Smoother curves
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [
                        Configuration.primaryColor.opacity(0.6),
                        Configuration.primaryColor.opacity(0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                
                LineMark(
                    x: .value("Time", item.time),
                    y: .value("Heart Rate", item.rate)
                )
                .interpolationMethod(.catmullRom) // Smoother curves
                .foregroundStyle(Configuration.primaryColor)
                .lineStyle(StrokeStyle(lineWidth: isExpanded ? 2.5 : 2, lineCap: .round, lineJoin: .round))
                
                if isExpanded && chartData.count < 30 {
                    PointMark(
                        x: .value("Time", item.time),
                        y: .value("Heart Rate", item.rate)
                    )
                    .foregroundStyle(Configuration.primaryColor)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: isExpanded ? 30 : 60)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(formatTime(date))
                                .font(isExpanded ? .caption : .caption2)
                                .rotationEffect(.degrees(isExpanded ? -30 : 0))
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
                            .font(isExpanded ? .caption : .caption2)
                            .foregroundColor(Configuration.secondaryTextColor)
                    }
                    AxisTick()
                        .foregroundStyle(Configuration.secondaryTextColor)
                    AxisGridLine()
                        .foregroundStyle(Configuration.secondaryTextColor.opacity(0.2))
                }
            }
            .frame(height: isExpanded ? 300 : 180)
            .chartYScale(domain: yAxisRange)
            .animation(.easeInOut, value: chartData.count) // Smooth transitions when data changes
        }
        .padding(isExpanded ? 20 : 16)
        .background(Configuration.cardBackgroundColor)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

// Identifiable data point for ChartView
struct HeartRateDataPoint: Identifiable {
    var id: Int
    var time: Date
    var rate: Double
}

struct StatBox: View {
    let title: String
    let value: Int
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(Configuration.primaryColor)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(Configuration.secondaryTextColor)
            }
            
            Text("\(value)")
                .font(.title3.bold())
                .foregroundColor(Configuration.primaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Configuration.primaryColor.opacity(0.1))
        .cornerRadius(10)
    }
}

extension StatBox {
    init(title: String, value: Int) {
        self.init(title: title, value: value, icon: "heart.fill")
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
            
            // Empty data test
            HeartRateGraph(data: [])
                .previewDisplayName("Empty Data (Shows Placeholder)")
        }
        .padding()
        .background(Configuration.backgroundColor)
    }
}
