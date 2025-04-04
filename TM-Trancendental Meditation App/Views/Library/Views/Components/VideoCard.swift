//
//  VideoCard.swift
//  TM-Trancendental Meditation App
//
//  Created by Tazi Grigolia on 10/23/24.
//

import SwiftUI

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
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Configuration.primaryColor.opacity(0.3), lineWidth: 1)
            )
            
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
        .background(Configuration.primaryColor.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview("Light Mode") {
    let sampleVideo = Video(
        id: "sample123",
        title: "15-Minute Guided Meditation for Beginners",
        thumbnailURL: "https://i.ytimg.com/vi/sample123/maxresdefault.jpg",
        channelTitle: "Meditation Channel",
        publishedAt: "2024-10-23",
        description: "A gentle introduction to meditation practice. Perfect for beginners who want to start their meditation journey. This session includes basic breathing techniques and mindfulness exercises."
    )
    
    return VideoCard(video: sampleVideo)
        .padding()
        .background(Configuration.backgroundColor)
        .environment(\.colorScheme, .light)
}


