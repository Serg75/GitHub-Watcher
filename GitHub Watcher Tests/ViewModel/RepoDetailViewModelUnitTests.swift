//
//  RepoDetailViewModelUnitTests.swift
//  GitHub WatcherTests
//
//  Created by Sergey Slobodenyuk on 2023-02-21.
//

import XCTest
import Combine
@testable import GitHub_Watcher

final class RepoDetailViewModelUnitTests: XCTestCase {

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

    func test_FetchContributors_EmitsProperRequest() {

        let url = MockedData.ringoRepo2ContributorsURL.absoluteString
        let requested = XCTestExpectation(description: "requested")
        let request = MockGitHubRequest(urls: [url], model: Contributors.self, expectation: requested)
        let sut = RepoDetailViewModel(request: request, repo: MockedData.ringoRepo2)

        sut.fetchContributors()
        
        wait(for: [requested], timeout: 1)
    }

    func test_FetchLanguages_EmitsProperRequest() {

        let url = MockedData.ringoRepo2LanguagesURL.absoluteString
        let requested = XCTestExpectation(description: "requested")
        let request = MockGitHubRequest(urls: [url], model: LanguagesIn.self, expectation: requested)
        let sut = RepoDetailViewModel(request: request, repo: MockedData.ringoRepo2)

        sut.fetchLanguages()
        
        wait(for: [requested], timeout: 1)
    }

}
