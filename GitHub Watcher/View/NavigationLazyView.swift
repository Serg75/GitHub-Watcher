//
//  NavigationLazyView.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-19.
//

import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
