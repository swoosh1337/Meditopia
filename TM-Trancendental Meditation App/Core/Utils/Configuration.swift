import Foundation
import SwiftUICore
import SwiftUI

enum Configuration {
    static let youtubeApiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "YOUTUBE_API_KEY") as? String else {
            fatalError("YouTube API Key not found")
        }
        return apiKey
    }()

    static let backgroundColor = Color(red: 1.0, green: 1.0, blue: 0.9)
}
