import SwiftUI

enum Configuration {
    static let youtubeApiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "YOUTUBE_API_KEY") as? String else {
            fatalError("YouTube API Key not found")
        }
        return apiKey
    }()
    
    static let primaryColor = Color(red: 0.545, green: 0.271, blue: 0.075) // Rich brown
    static let backgroundColor = Color(red: 0.976, green: 0.949, blue: 0.929)  // Light beige #F9F2ED
    static let textColor = Color.black
    static let secondaryTextColor = Color.gray.opacity(0.8)
    static let cardBackgroundColor = Color(red: 0.957, green: 0.918, blue: 0.886) // Light brown #F4EAE2
    
    static func adaptiveBackgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : backgroundColor
    }
    
    static func adaptiveTextColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : textColor
    }
}
