//
//  AvatarView.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-19.
//

import SwiftUI

@ViewBuilder
func avatarView(for url: String, size: Int) -> some View {
    HStack {
        AsyncImage(url: URL(string: url), transaction: Transaction(animation: .spring())) { phase in
            switch phase {
            case .empty:
                ActivityIndicatorView(style: .medium)
                
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                
            case .failure(_):
                Image(systemName: "exclamationmark.icloud")
                    .resizable()
                    .scaledToFit()
                    .padding(5)
                
            @unknown default:
                Image(systemName: "exclamationmark.icloud")
            }
        }
        .frame(width: CGFloat(size), height: CGFloat(size))
        .background(Color(.white))
        .clipShape(Capsule())
        .overlay(
            Circle()
                .strokeBorder(.gray, lineWidth: 0.7)
        )
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        avatarView(for: PreviewData.AvatarURL, size: 100)
            .previewLayout(.sizeThatFits)
    }
}
