import SwiftUI
import Charts

struct HeartRateGraph: View {
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
                        .foregroundColor(.primary)
                    
                    Text("BPM over time")
                        .font(isExpanded ? .title3 : .subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isExpanded {
                    Button(action: {
                        onDismiss?()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
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
                        }
                        AxisTick()
                        AxisGridLine()
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
            .frame(height: isExpanded ? UIScreen.main.bounds.height * 0.4 : 200)
            .chartYScale(domain: 40...120)
        }
        .padding(isExpanded ? 20 : 16)
        .background(Color(red: 1.0, green: 1.0, blue: 0.9))
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
                .foregroundColor(.secondary)
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
    static var previews: some View {
        HeartRateGraph(data: [
            (Date().addingTimeInterval(-300), 70),
            (Date().addingTimeInterval(-240), 72),
            (Date().addingTimeInterval(-180), 68),
            (Date().addingTimeInterval(-120), 71),
            (Date().addingTimeInterval(-60), 73),
            (Date(), 69)
        ])
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
}
