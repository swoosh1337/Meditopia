import SwiftUI

enum Configuration {
    static let youtubeApiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "YOUTUBE_API_KEY") as? String else {
            fatalError("YouTube API Key not found")
        }
        return apiKey
    }()
    
    static let backgroundColor = Color(red: 1.0, green: 1.0, blue: 0.9)
    static let textColor = Color.black
    static let secondaryTextColor = Color.gray.opacity(0.8)
    static let cardBackgroundColor = Color(red: 1.0, green: 1.0, blue: 0.9).opacity(0.5)
    
    static func adaptiveBackgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : backgroundColor
    }
    
    static func adaptiveTextColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : textColor
    }
}
