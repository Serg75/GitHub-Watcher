//
//  RepoListView.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-18.
//

import SwiftUI

struct RepoListView: View {
    
    @ObservedObject private(set) var viewModel: RepoListViewModel
    @State private var showModal = false

    var body: some View {
        VStack {
            Text("Repositories for:")
                .font(.title)
            HStack {
                avatarView(for: viewModel.owner.avatarUrl, size: 40)
                Text(viewModel.owner.login)
                    .font(.title3)
            }

            contentView()
                .onAppear {
                    viewModel.fetchRepos()
                }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Results -

extension RepoListView {
        
    @ViewBuilder
    private func contentView() -> some View {
        switch viewModel.repos {
            case .notRequested: notRequestedView()
            case .isLoading: loadingView(for: .large)
            case .loaded(let results): loadedView(for: results)
            case .failed: errorView()
        }
    }
    
    @ViewBuilder
    private func notRequestedView() -> some View {
        Spacer()
    }
    
    @ViewBuilder
    private func loadingView(for style: UIActivityIndicatorView.Style) -> some View {
        Spacer()
        ActivityIndicatorView(style: style)
            .padding()
        Spacer()
    }
    
    @ViewBuilder
    private func loadedView(for results: [Repo]) -> some View {
        if results.isEmpty {
            noResultsView()
        } else {
            resultsView(for: results)
        }
    }
    
    @ViewBuilder
    private func noResultsView() -> some View {
        Spacer()
        Text("No results found")
        Spacer()
    }
    
    @ViewBuilder
    private func errorView() -> some View {
        Spacer()
        Text("Oops, Something went wrong!")
            .foregroundColor(.red)
        Spacer()
    }
    
    @ViewBuilder
    private func resultsView(for results: [Repo]) -> some View {
        List {
            ForEach(results, id: \.id) { item in
                NavigationLink(
                    destination: NavigationLazyView(
                        RepoDetailView(
                            viewModel:
                                RepoDetailViewModel(
                                    request: viewModel.request,
                                    repo: item))))
                {
                    repositoryRow(for: item)
                }
            }
        }
    }
    
    @ViewBuilder
    private func repositoryRow(for item: Repo) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(item.description ?? "")
                    .font(.footnote)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                    .foregroundColor(Color(.systemGray))
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView(viewModel: RepoListViewModel(request: PreviewData.Request, reposUrl: PreviewData.ReposURL, owner: PreviewData.SingleUser))
    }
}
