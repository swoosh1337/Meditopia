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
