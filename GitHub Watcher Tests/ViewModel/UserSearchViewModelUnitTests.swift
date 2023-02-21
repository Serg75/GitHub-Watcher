//
//  UserSearchViewModelUnitTests.swift
//  GitHub WatcherTests
//
//  Created by Sergey Slobodenyuk on 2023-02-21.
//

import XCTest
import Combine
@testable import GitHub_Watcher

final class UserSearchViewModelUnitTests: XCTestCase {

    class MockGitHubRequest: GitHubRequestProtocol {
        let session: URLSession = URLSession.shared
        let baseURL: String = ""
        let expectedQueries: [GitHubQuery]
        let expectedModel: Any.Type
        let expectation: XCTestExpectation
        var counter = 0
        
        init<T>(queries: [GitHubQuery], model: T.Type, expectation: XCTestExpectation) where T: Equatable {
            expectedQueries = queries
            expectedModel = model
            self.expectation = expectation
        }

        func fetch<ModelType>(query: GitHub_Watcher.GitHubQuery,
                              model: ModelType.Type) -> AnyPublisher<ModelType, Error> where ModelType : Decodable {
            
            XCTAssertEqual(query, expectedQueries[counter])
            XCTAssert(model == expectedModel)
            expectation.fulfill()
            counter += 1
            
            return Empty().eraseToAnyPublisher()
        }
        
        func fetchPlainURL<ModelType>(url:
                                      String, model: ModelType.Type) -> AnyPublisher<ModelType, Error> where ModelType : Decodable {
            
            return Empty().eraseToAnyPublisher()
        }
    }
    
    func test_PlaceSearchString_EmitsProperRequest() {

        let searchString = "Ringo Starr"
        let query = GitHubQuery(query: searchString, pageNumber: 1)
        let requested = XCTestExpectation(description: "requested")
        
        let request = MockGitHubRequest(queries: [query], model: Users.self, expectation: requested)
        let sut = UserSearchViewModel(request: request)

        sut.searchText = searchString
        
        wait(for: [requested], timeout: 1)
    }

    func test_ClearSearchString_DoesNotEmitRequest() {

        let searchString = "Ringo Starr"
        let query = GitHubQuery(query: searchString, pageNumber: 1)
        let requested = XCTestExpectation(description: "requested")
        requested.assertForOverFulfill = true
        
        let request = MockGitHubRequest(queries: [query], model: Users.self, expectation: requested)
        let sut = UserSearchViewModel(request: request)

        sut.searchText = searchString
        wait(for: [requested], timeout: 1)
        
        sut.searchText = ""

        // pause 2 seconds
        let sleep = XCTestExpectation(description: "pause ended")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            sleep.fulfill()
        }
        wait(for: [sleep], timeout: 3)
    }
    
    func test_UpdateSearchString_EmitsSeveralRequests() {
        
        let searchString1 = "Ringo Starr"
        let searchString2 = "Jenna Ortega"
        let query1 = GitHubQuery(query: searchString1, pageNumber: 1)
        let query2 = GitHubQuery(query: searchString2, pageNumber: 1)
        let requested = XCTestExpectation(description: "requested")
        requested.expectedFulfillmentCount = 2
        requested.assertForOverFulfill = true
        
        let request = MockGitHubRequest(queries: [query1, query2], model: Users.self, expectation: requested)
        let sut = UserSearchViewModel(request: request)

        sut.searchText = searchString1
        
        // pause 1 second
        let sleep = XCTestExpectation(description: "pause ended")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sleep.fulfill()
        }
        wait(for: [sleep], timeout: 2)

        sut.searchText = searchString2

        wait(for: [requested], timeout: 1)
    }
    
    func test_LoadMore_EmitsComplimentedRequest() {

        let searchString = "Ringo Starr"
        let query1 = GitHubQuery(query: searchString, pageNumber: 1)
        // same pageNumber because it increments when data is received
        let query2 = GitHubQuery(query: searchString, pageNumber: 1)
        let requested = XCTestExpectation(description: "requested")
        requested.expectedFulfillmentCount = 2
        requested.assertForOverFulfill = true
        
        let request = MockGitHubRequest(queries: [query1, query2], model: Users.self, expectation: requested)
        let sut = UserSearchViewModel(request: request)

        sut.searchText = searchString
        
        // pause 1 second
        let sleep = XCTestExpectation(description: "pause ended")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sleep.fulfill()
        }
        wait(for: [sleep], timeout: 2)

        sut.loadMoreResults()

        wait(for: [requested], timeout: 1)
    }
}
