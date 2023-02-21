//
//  UserSearchViewModelTests.swift
//  GitHub WatcherTests
//
//  Created by Sergey Slobodenyuk on 2023-02-20.
//

import XCTest
import Combine
import Mocker
@testable import GitHub_Watcher

final class UserSearchViewModelTests: XCTestCase {
    
    static let baseURL = "https://api.github.com"
    static var mocRequest: GitHubRequestProtocol!
    static let testBundle = Bundle(for: UserSearchViewModelTests.self)

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
        
        let sut = UserSearchViewModel(request: PreviewData.Request)
        
        XCTAssertEqual(sut.searchResults, Loadable<Users>.notRequested)
        XCTAssertEqual(sut.searchResults.value, nil)
    }
    
    func test_PlaceSearchString_PopulatesResults() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoRequestURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.RingoStarr_JSON.data
        ])
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = UserSearchViewModel(request: UserSearchViewModelTests.mocRequest)

        let isLoaded = expectValue(of: sut.$searchResults.eraseToAnyPublisher(), equals: [{ $0.isLoaded }])

        sut.searchText = "Ringo Starr"

        wait(for: [response], timeout: 1)
        wait(for: [isLoaded.expectation], timeout: 1)

        XCTAssertEqual(sut.searchResults, Loadable<Users>.loaded(MockedData.ringoUsers))
        XCTAssertEqual(sut.searchResults.value?.totalCount, 3)
    }

    func test_ClearSearchString_RemovesResults() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoRequestURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.RingoStarr_JSON.data
        ])
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = UserSearchViewModel(request: UserSearchViewModelTests.mocRequest)

        let isLoaded = expectValue(of: sut.$searchResults.eraseToAnyPublisher(), equals: [{ $0.isLoaded }])

        sut.searchText = "Ringo Starr"

        wait(for: [response], timeout: 1)
        wait(for: [isLoaded.expectation], timeout: 1)

        sut.searchText = ""

        XCTAssertEqual(sut.searchResults, Loadable<Users>.notRequested)
        XCTAssertEqual(sut.searchResults.value?.totalCount, nil)
    }

    func test_UpdateSearchString_PopulatesNewResults() {

        let response1 = XCTestExpectation(description: "response")

        var mock1 = Mock(url: MockedData.ringoRequestURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.RingoStarr_JSON.data
        ])
        mock1.completion = { response1.fulfill() }
        mock1.register()

        // first search

        let sut = UserSearchViewModel(request: UserSearchViewModelTests.mocRequest)

        let isLoaded1 = expectValue(of: sut.$searchResults.eraseToAnyPublisher(), equals: [{ $0.value?.totalCount ?? 0 == 3 }])

        sut.searchText = "Ringo Starr"

        wait(for: [response1], timeout: 1)
        wait(for: [isLoaded1.expectation], timeout: 1)

        // pause 2 seconds
        let sleep = XCTestExpectation(description: "pause ended")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            sleep.fulfill()
        }
        wait(for: [sleep], timeout: 10)

        // second search

        let response2 = XCTestExpectation(description: "response")

        var mock2 = Mock(url: MockedData.jennaRequestURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.JennaOrtega_JSON.data
        ])
        mock2.completion = { response2.fulfill() }
        mock2.register()

        let isLoaded2 = expectValue(of: sut.$searchResults.eraseToAnyPublisher(), equals: [{ $0.value?.totalCount ?? 0 == 2 }])

        sut.searchText = "Jenna Ortega"

        wait(for: [response2], timeout: 1)
        wait(for: [isLoaded2.expectation], timeout: 10)

        XCTAssertEqual(sut.searchResults, Loadable<Users>.loaded(MockedData.jennaUsers))
        XCTAssertEqual(sut.searchResults.value?.totalCount, 2)
    }

    func test_LoadMore_AddsNewResults() {

        let response = XCTestExpectation(description: "response")

        var mock1 = Mock(url: MockedData.funnyRequestURL1, dataType: .json, statusCode: 200, data: [
            .get: MockedData.funnyboxPage1_JSON.data
        ])
        mock1.completion = { response.fulfill() }
        mock1.register()

        let sut = UserSearchViewModel(request: UserSearchViewModelTests.mocRequest)

        let isLoaded1 = expectValue(of: sut.$searchResults.eraseToAnyPublisher(), equals: [{ $0.value?.items.count ?? 0 == 5 }])

        sut.searchText = "funnybox"

        wait(for: [isLoaded1.expectation], timeout: 1)

        // pause 2 seconds
        let sleep = XCTestExpectation(description: "pause ended")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            sleep.fulfill()
        }
        wait(for: [sleep], timeout: 10)

        // second page

        var mock2 = Mock(url: MockedData.funnyRequestURL2, dataType: .json, statusCode: 200, data: [
            .get: MockedData.funnyboxPage2_JSON.data
        ])
        mock2.completion = { response.fulfill() }
        mock2.register()

        let isLoaded2 = expectValue(of: sut.$searchResults.eraseToAnyPublisher(), equals: [{ $0.value?.items.count == 7 }])

        sut.loadMoreResults()

        wait(for: [isLoaded2.expectation], timeout: 10)

        XCTAssertEqual(sut.searchResults, Loadable<Users>.loaded(MockedData.funnyUsers))
        XCTAssertEqual(sut.searchResults.value?.totalCount, 7)
    }

    func test_SlowInternet_NoQuickResults() {

        var mock = Mock(url: MockedData.ringoRequestURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.RingoStarr_JSON.data
        ])
        mock.delay = DispatchTimeInterval.seconds(10)
        mock.register()

        let sut = UserSearchViewModel(request: UserSearchViewModelTests.mocRequest)

        sut.searchText = "Ringo Starr"

        // pause 2 seconds
        let sleep = XCTestExpectation(description: "pause ended")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            sleep.fulfill()
        }
        wait(for: [sleep], timeout: 10)

        XCTAssertEqual(sut.searchResults, Loadable<Users>.isLoading(last: nil, cancelBag: CancelBag()))
        XCTAssertEqual(sut.searchResults.value, nil)
    }

    func test_SlowInternet_ResultsWithDelay() {

        let response = XCTestExpectation(description: "response")

        var mock = Mock(url: MockedData.ringoRequestURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.RingoStarr_JSON.data
        ])
        mock.delay = DispatchTimeInterval.seconds(10)
        mock.completion = { response.fulfill() }
        mock.register()

        let sut = UserSearchViewModel(request: UserSearchViewModelTests.mocRequest)

        let isLoading = expectValue(of: sut.$searchResults.eraseToAnyPublisher(), equals: [{ $0 == .isLoading(last: nil, cancelBag: CancelBag()) }])

        sut.searchText = "Ringo Starr"

        // wait untill results start loading
        wait(for: [isLoading.expectation], timeout: 1)

        wait(for: [response], timeout: 15)

        // small pause
        let sleep = XCTestExpectation(description: "pause ended")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sleep.fulfill()
        }
        wait(for: [sleep], timeout: 2)

        XCTAssertEqual(sut.searchResults, Loadable<Users>.loaded(MockedData.ringoUsers))
        XCTAssertEqual(sut.searchResults.value?.totalCount, 3)
    }

    func test_NoInternet_EmptyResults() {

        var mock = Mock(url: MockedData.ringoRequestURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.RingoStarr_JSON.data
        ])
        mock.delay = DispatchTimeInterval.seconds(60)
        mock.register()

        let sut = UserSearchViewModel(request: UserSearchViewModelTests.mocRequest)

        sut.searchText = "Ringo Starr"

        // quite big pause
        let sleep = XCTestExpectation(description: "pause ended")
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            sleep.fulfill()
        }
        wait(for: [sleep], timeout: 25)

        XCTAssertEqual(sut.searchResults, Loadable<Users>.isLoading(last: nil, cancelBag: CancelBag()))
        XCTAssertEqual(sut.searchResults.value, nil)
    }
    
}
