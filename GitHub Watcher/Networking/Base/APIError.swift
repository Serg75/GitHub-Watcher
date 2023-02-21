//
//  APIError.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-20.
//

import Foundation

enum APIError: Swift.Error {
    case invalidURL
    case httpCode(HTTPCode)
    case unexpectedResponse
    case imageProcessing([URLRequest])
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .invalidURL: return "Invalid URL"
            case let .httpCode(code): return "Unexpected HTTP code: \(code)"
            case .unexpectedResponse: return "Unexpected response from the server"
            case .imageProcessing: return "Unable to load image"
        }
    }
}
