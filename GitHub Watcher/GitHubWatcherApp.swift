//
//  GitHub_WatcherApp.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-17.
//

import SwiftUI

@main
struct GitHubWatcherApp: App {
    var body: some Scene {
        WindowGroup {
            let environment = AppEnvironment.bootstrap()
            UserSearchView(viewModel: UserSearchViewModel(request: environment.webRequest))
        }
    }
}
