//
//  RepoDetailViewModel.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-18.
//

import Foundation
import Combine
import SwiftUI

typealias LanguagesIn = Dictionary<String, Int>
typealias Languages = [Language]
typealias Contributors = [User]

struct Language: Identifiable, Equatable {
    var id: UUID = UUID()
    
    let name: String
    let value: Double
    let color: Color
    
    // compare non-generated values only
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.name == rhs.name && lhs.value == rhs.value
    }
}

final class RepoDetailViewModel: ObservableObject {
    
    @Published var contributorsUrl: String
    @Published var languagesURL: String
    @Published var contributors: Loadable<Contributors>
    @Published var languages: Loadable<Languages>
    
    let repo: Repo
    let request: GitHubRequestProtocol
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(request: GitHubRequestProtocol,
         repo: Repo,
         contributors: Loadable<Contributors> = .notRequested,
         languages: Loadable<Languages> = .notRequested) {
        
        _contributors = .init(initialValue: contributors)
        _languages = .init(initialValue: languages)
        self.request = request
        self.repo = repo
        self.contributorsUrl = repo.contributorsUrl
        self.languagesURL = repo.languagesUrl
    }
    
    func fetchContributors() {

        self.request
            .fetchPlainURL(url: contributorsUrl, model: Contributors.self)
            .handleEvents(receiveRequest: { [weak self] _ in
                self?.contributors
                    .setIsLoading(cancelBag: CancelBag())
            })
            .catch { error -> AnyPublisher<Contributors, Never> in
                self.contributors = .failed(error)
                return Empty().eraseToAnyPublisher()
            }
            .sink(receiveValue: { [weak self] in
                self?.contributors = .loaded($0)
            })
            .store(in: &subscriptions)
    }

    func fetchLanguages() {

        self.request
            .fetchPlainURL(url: languagesURL, model: LanguagesIn.self)
            .handleEvents(receiveRequest: { [weak self] _ in
                self?.languages
                    .setIsLoading(cancelBag: CancelBag())
            })
            .catch { error -> AnyPublisher<LanguagesIn, Never> in
                self.languages = .failed(error)
                return Empty().eraseToAnyPublisher()
            }
            .map { languages -> Languages in
                let total = Double(languages.compactMap { $0.value }.reduce(0, +)) / 100.0
                return languages
                    .map { Language(name: $0.key, value: Double($0.value) / total, color: Color.random) }
                    .sorted { $0.value > $1.value }
            }
            .sink(receiveValue: { [weak self] in
                self?.languages = .loaded($0)
            })
            .store(in: &subscriptions)
    }
}
