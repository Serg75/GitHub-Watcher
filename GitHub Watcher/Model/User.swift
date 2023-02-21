//
//  User.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-17.
//

import Foundation

struct Users: Codable, Equatable {
    let totalCount: Int
    var items: [User]
}

struct User: Codable, Identifiable, Equatable {
    let id: Int
    let login: String
    let avatarUrl: String
    let type: String?
    let reposUrl: String
}
