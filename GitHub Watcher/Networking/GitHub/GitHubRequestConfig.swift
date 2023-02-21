//
//  WebRequestConfigurable.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-17.
//

import Foundation

final class GitHubRequestConfig: WebRequestConfigurable {
    
    var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration)
    }
    
    var baseURL: String { "https://api.github.com" }
}
