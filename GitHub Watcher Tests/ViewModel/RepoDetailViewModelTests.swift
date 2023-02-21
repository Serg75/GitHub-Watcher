//
//  RepoDetailViewModelTests.swift
//  GitHub WatcherTests
//
//  Created by Sergey Slobodenyuk on 2023-02-21.
//

import XCTest
import Combine
import Mocker
@testable import GitHub_Watcher

final class RepoDetailViewModelTests: XCTestCase {

    static let baseURL = "https://api.github.com"
    static var mocRequest: GitHubRequestProtocol!
//    static let testBundle = Bundle(for: RepoDetailViewModelTests.self)

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
        
        let sut = RepoDetailViewModel(request: RepoDetailViewModelTests.mocRequest,
                                      repo: MockedData.ringoRepo1)

        XCTAssertEqual(sut.contributors, Loadable<Contributors>.notRequested)
        XCTAssertEqual(sut.languages, Loadable<Languages>.notRequested)
        XCTAssertEqual(sut.contributors.value, nil)
        XCTAssertEqual(sut.languages.value, nil)
    }

    func test_FetchContributors_PopulatesResults() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoRepo2ContributorsURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.ringoRepo2Contributors_JSON.data
        ])
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = RepoDetailViewModel(request: RepoDetailViewModelTests.mocRequest,
                                      repo: MockedData.ringoRepo2)

        let isLoaded = expectValue(of: sut.$contributors.eraseToAnyPublisher(), equals: [{ $0.isLoaded }])

        sut.fetchContributors()

        wait(for: [response], timeout: 1)
        wait(for: [isLoaded.expectation], timeout: 1)

        XCTAssertEqual(sut.contributors, Loadable<Contributors>.loaded(MockedData.ringoRepo2Contributors))
        XCTAssertEqual(sut.contributors.value?.count, 1)
    }

    func test_FetchLanguages_PopulatesResults() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoRepo2LanguagesURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.ringoRepo2Languages_JSON.data
        ])
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = RepoDetailViewModel(request: RepoDetailViewModelTests.mocRequest,
                                      repo: MockedData.ringoRepo2)

        let isLoaded = expectValue(of: sut.$languages.eraseToAnyPublisher(), equals: [{ $0.isLoaded }])

        sut.fetchLanguages()

        wait(for: [response], timeout: 1)
        wait(for: [isLoaded.expectation], timeout: 1)

        XCTAssertEqual(sut.languages, Loadable<Languages>.loaded(MockedData.ringoRepo2Languages))
        XCTAssertEqual(sut.languages.value?.count, 1)
    }

    func test_BrokenResponse_MakesContributorsFailed() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoRepo2ContributorsURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.brokenContributors_JSON.data
        ])
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = RepoDetailViewModel(request: RepoDetailViewModelTests.mocRequest,
                                      repo: MockedData.ringoRepo2)

        let isFailed = expectValue(of: sut.$contributors.eraseToAnyPublisher(), equals: [{ $0.isFailed }])

        sut.fetchContributors()

        wait(for: [response], timeout: 1)
        wait(for: [isFailed.expectation], timeout: 1)

        XCTAssertEqual(sut.contributors.value, nil)
    }

    func test_BrokenResponse_MakesLanguagesFailed() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoRepo2LanguagesURL, dataType: .json, statusCode: 200, data: [
            .get: "{".data(using: .utf8)!
        ])
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = RepoDetailViewModel(request: RepoDetailViewModelTests.mocRequest,
                                      repo: MockedData.ringoRepo2)

        let isFailed = expectValue(of: sut.$languages.eraseToAnyPublisher(), equals: [{ $0.isFailed }])

        sut.fetchLanguages()

        wait(for: [response], timeout: 1)
        wait(for: [isFailed.expectation], timeout: 1)

        XCTAssertEqual(sut.languages.value, nil)
    }

    func test_ResponseError_MakesContributorsFailed() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoRepo2ContributorsURL, dataType: .json, statusCode: 204, data: [.get: Data()], requestError: APIError.unexpectedResponse)
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = RepoDetailViewModel(request: RepoDetailViewModelTests.mocRequest,
                                      repo: MockedData.ringoRepo2)

        let isFailed = expectValue(of: sut.$contributors.eraseToAnyPublisher(), equals: [{ $0.isFailed }])

        sut.fetchContributors()

        wait(for: [response], timeout: 1)
        wait(for: [isFailed.expectation], timeout: 1)

        XCTAssertEqual(sut.contributors.value, nil)
    }

    func test_ResponseError_MakesLanguagesFailed() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoRepo2LanguagesURL, dataType: .json, statusCode: 204, data: [.get: Data()], requestError: APIError.unexpectedResponse)
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = RepoDetailViewModel(request: RepoDetailViewModelTests.mocRequest,
                                      repo: MockedData.ringoRepo2)

        let isFailed = expectValue(of: sut.$languages.eraseToAnyPublisher(), equals: [{ $0.isFailed }])

        sut.fetchLanguages()

        wait(for: [response], timeout: 1)
        wait(for: [isFailed.expectation], timeout: 1)

        XCTAssertEqual(sut.languages.value, nil)
    }

}
