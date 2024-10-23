import SwiftUI
import Charts

struct HeartRateGraph: View {
    let data: [(Date, Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Heart Rate")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("BPM over time")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Chart(data, id: \.0) { item in
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
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel(format: .dateTime.hour().minute())
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 40...120)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
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
