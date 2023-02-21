//
//  UserSearchViewModel.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-17.
//

import Foundation
import Combine

final class UserSearchViewModel: ObservableObject {
    
    @Published var searchText = ""
    @Published var searchResults: Loadable<Users>
    @Published var loadMore: Loadable<Bool>
    
    let request: GitHubRequestProtocol
    
    private var subscriptions = Set<AnyCancellable>()
        
    init(request: GitHubRequestProtocol,
         searchResults: Loadable<Users> = .notRequested,
         loadMore: Loadable<Bool> = .notRequested)
    {
        _searchResults = .init(initialValue: searchResults)
        _loadMore = .init(initialValue: loadMore)
        self.request = request
        setupContinousSearchBinding()
        setupClearSearchBinding()
    }
    
    // pagination
    private var pagination: (currentPage: Int,
                             results: Users?) = (0, nil)

    private func setupContinousSearchBinding() {
        $searchText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .compactMap { [weak self] query in
                self?.request
                    .fetch(query:GitHubQuery(query: query, pageNumber: 1), model: Users.self)
                    .handleEvents(receiveRequest: { [weak self] _ in
                        self?.searchResults
                             .setIsLoading(cancelBag: CancelBag())
                    })
                    .catch { error -> AnyPublisher<Users, Never> in
                        return Empty().eraseToAnyPublisher()
                    }
            }
            .switchToLatest()
            .sink(receiveValue: { [weak self] in
                    self?.pagination.currentPage = 0
                    self?.updatePaginationAnchors(for: $0)
                    self?.searchResults = .loaded($0)
                  })
            .store(in: &subscriptions)
    }
    
    private func setupClearSearchBinding() {
        $searchText
            .filter { $0.isEmpty }
            .sink(receiveValue: { [weak self] _ in
                self?.searchResults = .notRequested
            })
            .store(in: &subscriptions)
    }
}

// MARK: - Error handling -

extension UserSearchViewModel {
    
    func hasErroneousResults(for result: Users) -> Bool {
        return result.totalCount == -1
    }
    
    func hasNoResults(for result: Users) -> Bool {
        return result.items.isEmpty
    }
}

// MARK: - Pagination -

extension UserSearchViewModel {
    
    func loadMoreResults() {
        request
            .fetch(
                query: GitHubQuery(query: searchText, pageNumber: pagination.currentPage + 1),
                model: Users.self)
            .handleEvents(receiveRequest: { [weak self] _ in
                self?.loadMore
                     .setIsLoading(cancelBag: CancelBag())
            })
            .sink { [weak self] result in
                switch result {
                    case .failure(let error):
                        self?.loadMore = .failed(error)
                    case .finished:
                        break
                }
            } receiveValue: { [weak self] result in
                if let pagination = self?.pagination, var results = pagination.results {
                    results.items.append(contentsOf: result.items)
                    self?.updatePaginationAnchors(for: results)
                    self?.searchResults = .loaded(results)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func updatePaginationAnchors(for results: Users) {
        pagination.currentPage += 1
        pagination.results = results
        loadMore = .loaded(results.totalCount > results.items.count)
    }
}
