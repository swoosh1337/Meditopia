//
//  LibraryView.swift
//  TM.io
//
//  Created by Tazi Grigolia on 10/21/24.
//

import SwiftUI
import SafariServices

struct LibraryView: View {
    @StateObject private var youtubeService = YouTubeService()
    @State private var selectedVideo: Video?
    @State private var showingSafari = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                if youtubeService.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 20) {
                        ForEach(youtubeService.videos) { video in
                            VideoCard(video: video)
                                .onTapGesture {
                                    selectedVideo = video
                                    showingSafari = true
                                }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(red: 1.0, green: 1.0, blue: 0.9))
            .navigationTitle("Meditation Library")
            .sheet(isPresented: $showingSafari) {
                if let video = selectedVideo {
                    SafariView(url: video.videoURL)
                }
            }
        }
        .onAppear {
            if youtubeService.videos.isEmpty {
                youtubeService.fetchVideos()
            }
        }
    }
}

struct VideoCard: View {
    let video: Video
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: video.thumbnailImage) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(video.title)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            Text(video.channelTitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(video.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(15)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
