//
//  OtherExtensions.swift
//  GitHub WatcherTests
//
//  Created by Sergey Slobodenyuk on 2023-02-21.
//

import Foundation

extension Bundle {
    static let module = Bundle(for: MockedData.self)
}

extension URL {
    /// Returns a `Data` representation of the current `URL`. Force unwrapping as it's only used for tests.
    var data: Data {
        return try! Data(contentsOf: self)
    }
}

