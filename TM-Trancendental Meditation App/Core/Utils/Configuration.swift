import Foundation

enum Configuration {
    static let youtubeApiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "YOUTUBE_API_KEY") as? String else {
            fatalError("YouTube API Key not found")
        }
        return apiKey
    }()
}
