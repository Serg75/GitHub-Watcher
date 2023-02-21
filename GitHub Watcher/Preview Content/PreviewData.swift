//
//  PreviewData.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-19.
//

import Foundation

struct PreviewData {
    
    static var Request: GitHubRequestProtocol = {
        let configuration = GitHubRequestConfig()
        return GitHubRequest(session: configuration.session,
                             baseURL: configuration.baseURL)
    }()
    
    static var SingleRepo: Repo = {
        return Bundle.main.decodeJSON("repo", type: Repo.self)
    }()
    
    static var SingleUser: User = {
        return Bundle.main.decodeJSON("user", type: User.self)
    }()
    
    static var ReposURL: String = {
        return "https://api.github.com/users/DaDaMrX/repos"
    }()

    static var AvatarURL: String = {
        return "https://avatars.githubusercontent.com/u/18094391?v=4"
    }()
}
