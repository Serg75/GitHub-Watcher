//
//  RepoListViewModelTests.swift
//  GitHub WatcherTests
//
//  Created by Sergey Slobodenyuk on 2023-02-21.
//

import XCTest
import Combine
import Mocker
@testable import GitHub_Watcher

final class RepoListViewModelTests: XCTestCase {

    static let baseURL = "https://api.github.com"
    static var mocRequest: GitHubRequestProtocol!
//    static let testBundle = Bundle(for: UserSearchViewModelTests.self)

    override class func setUp() {
        super.setUp()
        mocRequest = GitHubRequest(session: URLSession.shared, baseURL: baseURL)
    }

    override func setUp() {
        super.setUp()
        Mocker.mode = .optout
    }

    override func tearDown() {
        Mocker.removeAll()
        Mocker.mode = .optout
        super.tearDown()
    }
    
    func test_InitialState_WithEmptyCollection() {
        
        let sut = RepoListViewModel(request: RepoListViewModelTests.mocRequest,
                                    reposUrl: MockedData.ringoReposURL.absoluteString,
                                    owner: MockedData.ringo3)

        XCTAssertEqual(sut.repos, Loadable<[Repo]>.notRequested)
        XCTAssertEqual(sut.repos.value, nil)
    }
 
    func test_FetchRepos_PopulatesResults() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoReposURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.ringoRepos_JSON.data
        ])
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = RepoListViewModel(request: RepoListViewModelTests.mocRequest,
                                    reposUrl: MockedData.ringoReposURL.absoluteString,
                                    owner: MockedData.ringo3)

        let isLoaded = expectValue(of: sut.$repos.eraseToAnyPublisher(), equals: [{ $0.isLoaded }])

        sut.fetchRepos()

        wait(for: [response], timeout: 1)
        wait(for: [isLoaded.expectation], timeout: 1)

        XCTAssertEqual(sut.repos, Loadable<[Repo]>.loaded(MockedData.ringoRepos))
        XCTAssertEqual(sut.repos.value?.count, 2)
    }

    func test_BrokenResponse_MakesReposFailed() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoReposURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.brokenRepos_JSON.data
        ])
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = RepoListViewModel(request: RepoListViewModelTests.mocRequest,
                                    reposUrl: MockedData.ringoReposURL.absoluteString,
                                    owner: MockedData.ringo3)

        let isFailed = expectValue(of: sut.$repos.eraseToAnyPublisher(), equals: [{ $0.isFailed }])

        sut.fetchRepos()

        wait(for: [response], timeout: 1)
        wait(for: [isFailed.expectation], timeout: 1)

        XCTAssertEqual(sut.repos.value, nil)
    }

    func test_ResponseError_MakesReposFailed() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoReposURL, dataType: .json, statusCode: 204, data: [.get: Data()], requestError: APIError.unexpectedResponse)
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = RepoListViewModel(request: RepoListViewModelTests.mocRequest,
                                    reposUrl: MockedData.ringoReposURL.absoluteString,
                                    owner: MockedData.ringo3)

        let isFailed = expectValue(of: sut.$repos.eraseToAnyPublisher(), equals: [{ $0.isFailed }])

        sut.fetchRepos()

        wait(for: [response], timeout: 1)
        wait(for: [isFailed.expectation], timeout: 1)

        XCTAssertEqual(sut.repos.value, nil)
    }

}
