import SwiftUI
import Combine

class LibraryViewModel: ObservableObject {
    @Published var selectedVideo: Video?
    @Published var showingSafari = false
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let youtubeService: YouTubeService
    private var cancellables = Set<AnyCancellable>()
    
    init(youtubeService: YouTubeService = YouTubeService()) {
        self.youtubeService = youtubeService
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind to videos
        youtubeService.$videos
            .receive(on: DispatchQueue.main)
            .assign(to: \.videos, on: self)
            .store(in: &cancellables)
        
        // Bind to loading state
        youtubeService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        // Bind to error
        youtubeService.$error
            .receive(on: DispatchQueue.main)
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
    }
    
    func fetchVideos() {
        youtubeService.fetchVideos()
    }
    
    func selectVideo(_ video: Video) {
        selectedVideo = video
        showingSafari = true
    }
}
