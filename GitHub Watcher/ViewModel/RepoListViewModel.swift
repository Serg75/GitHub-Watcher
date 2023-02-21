//
//  RepoListViewModel.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-17.
//

import Foundation
import Combine

final class RepoListViewModel: ObservableObject {
    
    @Published var reposUrl: String
    @Published var repos: Loadable<[Repo]>

    let owner: User
    let request: GitHubRequestProtocol

    private var subscriptions = Set<AnyCancellable>()

    init(request: GitHubRequestProtocol,
         reposUrl: String,
         owner: User,
         repos: Loadable<[Repo]> = .notRequested)
    {
        _repos = .init(initialValue: repos)
        self.reposUrl = reposUrl
        self.request = request
        self.owner = owner
    }
    
    func fetchRepos() {
        
        self.request
            .fetchPlainURL(url: reposUrl, model: [Repo].self)
            .handleEvents(receiveRequest: { [weak self] _ in
                self?.repos
                    .setIsLoading(cancelBag: CancelBag())
            })
            .catch { error -> AnyPublisher<[Repo], Never> in
                self.repos = .failed(error)
                return Empty().eraseToAnyPublisher()
            }
            .sink(receiveValue: { [weak self] in
                self?.repos = .loaded($0)
            })
            .store(in: &subscriptions)
    }
}
