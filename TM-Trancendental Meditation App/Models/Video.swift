import Foundation

struct Video: Identifiable, Codable {
    let id: String
    let title: String
    let thumbnailURL: String
    let channelTitle: String
    let publishedAt: String
    let description: String
    
    var videoURL: URL {
        URL(string: "https://www.youtube.com/watch?v=\(id)")!
    }
    
    var thumbnailImage: URL {
        URL(string: thumbnailURL)!
    }
}
