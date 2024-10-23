import Foundation

class YouTubeService: ObservableObject {
    private let apiKey = Configuration.youtubeApiKey
    private let searchQuery = "transcendental meditation technique guide"
    
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func fetchVideos() {
        isLoading = true
        
        let query = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(query)&type=video&maxResults=50&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(YouTubeResponse.self, from: data)
                    self?.videos = response.items.map { item in
                        Video(
                            id: item.id.videoId,
                            title: item.snippet.title,
                            thumbnailURL: item.snippet.thumbnails.high.url,
                            channelTitle: item.snippet.channelTitle,
                            publishedAt: item.snippet.publishedAt,
                            description: item.snippet.description
                        )
                    }
                } catch {
                    self?.error = error
                }
            }
        }.resume()
    }
}

// Response models
struct YouTubeResponse: Codable {
    let items: [YouTubeItem]
}

struct YouTubeItem: Codable {
    let id: VideoID
    let snippet: Snippet
}

struct VideoID: Codable {
    let videoId: String
}

struct Snippet: Codable {
    let publishedAt: String
    let channelTitle: String
    let title: String
    let description: String
    let thumbnails: Thumbnails
}

struct Thumbnails: Codable {
    let high: ThumbnailDetails
}

struct ThumbnailDetails: Codable {
    let url: String
}
