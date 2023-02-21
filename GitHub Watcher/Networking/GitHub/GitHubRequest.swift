//
//  GitHubRequest.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-17.
//

import Foundation
import Combine

struct GitHubQuery: Equatable {
    var query: String
    var pageNumber: Int
    var perPageResults = 12
}

protocol GitHubRequestProtocol: APIRequest {
    func fetch<ModelType: Decodable>(query: GitHubQuery, model: ModelType.Type) -> AnyPublisher<ModelType, Error>

    func fetchPlainURL<ModelType: Decodable>(url: String, model: ModelType.Type) -> AnyPublisher<ModelType, Error>
}

struct GitHubRequest: GitHubRequestProtocol {
    
    let session: URLSession
    let baseURL: String
    
    init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func fetch<ModelType: Decodable>(query: GitHubQuery, model: ModelType.Type) -> AnyPublisher<ModelType, Error> {
        
        return call(endpoint: API.searchUsers(params: query))
    }
    
    func fetchPlainURL<ModelType: Decodable>(url: String, model: ModelType.Type) -> AnyPublisher<ModelType, Error> {
        
        return callPlainURL(endpoint: API.plainURL(url))
    }
}

// MARK: - Endpoints

extension GitHubRequest {
    enum API {
        case searchUsers(params: GitHubQuery)
        case plainURL(_ url: String)
    }
}

extension GitHubRequest.API: APICall {
    var path: String {
        switch self {
            case .searchUsers(let params):
                var components = URLComponents()
                components.path = "/search/users"
                components.queryItems = [
                                            URLQueryItem(name: "q", value: params.query),
                                            URLQueryItem(name: "per_page", value: "\(params.perPageResults)"),
                                            URLQueryItem(name: "page", value: "\(params.pageNumber)")
                                        ]
                return components.url?.absoluteString ?? ""
            
            case .plainURL(let url):
                return url
        }
    }
    
    var method: String {
        switch self {
        case .searchUsers:
            return "GET"
        case .plainURL:
            return "GET"
        }
    }
    
    var headers: [String: String]? {
        return ["Accept": "application/json"]
    }
    
    func body() throws -> Data? {
        return nil
    }
}
