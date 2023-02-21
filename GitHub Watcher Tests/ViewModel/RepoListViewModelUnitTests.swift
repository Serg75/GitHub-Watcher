//
//  RepoListViewModelUnitTests.swift
//  GitHub WatcherTests
//
//  Created by Sergey Slobodenyuk on 2023-02-21.
//

import XCTest
import Combine
@testable import GitHub_Watcher

final class RepoListViewModelUnitTests: XCTestCase {

    class MockGitHubRequest: GitHubRequestProtocol {
        let session: URLSession = URLSession.shared
        let baseURL: String = ""
        let expectedURLs: [String]
        let expectedModel: Any.Type
        let expectation: XCTestExpectation
        var counter = 0
        
        init<T>(urls: [String], model: T.Type, expectation: XCTestExpectation) where T: Equatable {
            expectedURLs = urls
            expectedModel = model
            self.expectation = expectation
        }

        func fetch<ModelType>(query: GitHub_Watcher.GitHubQuery,
                              model: ModelType.Type) -> AnyPublisher<ModelType, Error> where ModelType : Decodable {

            return Empty().eraseToAnyPublisher()
        }
        
        func fetchPlainURL<ModelType>(url: String,
                                      model: ModelType.Type) -> AnyPublisher<ModelType, Error> where ModelType : Decodable {

            XCTAssertEqual(url, expectedURLs[counter])
            XCTAssert(model == expectedModel)
            expectation.fulfill()
            counter += 1
            
            return Empty().eraseToAnyPublisher()
        }
    }

    func test_FetchRepos_EmitsProperRequest() {

        let url = MockedData.ringoReposURL.absoluteString
        let requested = XCTestExpectation(description: "requested")
        let request = MockGitHubRequest(urls: [url], model: [Repo].self, expectation: requested)
        let sut = RepoListViewModel(request: request, reposUrl: url, owner: MockedData.ringo3)

        sut.fetchRepos()
        
        wait(for: [requested], timeout: 1)
    }

}
