//
//  Repo.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-17.
//

import Foundation

struct Repo: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let `private`: Bool
    let url: String
    let contributorsUrl: String
    let languagesUrl: String
    let owner: User?
    let description: String?
    let createdAt: Date?
}
