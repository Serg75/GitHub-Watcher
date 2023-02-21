//
//  AppEnvironment.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-17.
//

import Foundation

struct AppEnvironment {
    let webRequest: GitHubRequestProtocol
}

extension AppEnvironment {
    
    static func bootstrap() -> AppEnvironment {
        let request = configuredWebRequest(for: GitHubRequestConfig())
        return AppEnvironment(webRequest: request)
    }
    
    private static func configuredWebRequest(for configuration: WebRequestConfigurable) -> GitHubRequestProtocol {
        
        return GitHubRequest(session: configuration.session,
                             baseURL: configuration.baseURL)
    }

}
