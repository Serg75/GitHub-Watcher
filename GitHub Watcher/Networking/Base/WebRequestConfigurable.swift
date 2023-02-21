//
//  WebRequestConfigurable.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-20.
//

import Foundation

protocol WebRequestConfigurable {
    var session: URLSession { get }
    var baseURL: String { get }
}
