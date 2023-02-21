//
//  UserSearchView.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-17.
//

import SwiftUI

struct UserSearchView: View {
    
    @ObservedObject private(set) var viewModel: UserSearchViewModel
    @State private var showModal = false

    var body: some View {
        NavigationStack {
            contentView()
                .navigationTitle("GitHub Watcher")
        }
        .searchable(text: $viewModel.searchText, prompt: "User or organization")
        .disableAutocorrection(true)
    }
}

// MARK: - Results -

extension UserSearchView {
        
    @ViewBuilder
    private func contentView() -> some View {
        switch viewModel.searchResults {
            case .notRequested: notRequestedView()
            case .isLoading: loadingView(for: .large)
            case .loaded(let results): loadedView(for: results)
            case .failed: errorView()
        }
    }
    
    @ViewBuilder
    private func notRequestedView() -> some View {
        Text("Use search bar to find something")
    }
    
    @ViewBuilder
    private func loadingView(for style: UIActivityIndicatorView.Style) -> some View {
        ActivityIndicatorView(style: style)
            .padding()
    }
    
    @ViewBuilder
    private func loadedView(for results: Users) -> some View {
        if viewModel.hasErroneousResults(for: results) {
            errorView()
        } else if viewModel.hasNoResults(for: results) {
            noResultsView()
        } else {
            resultsView(for: results)
        }
    }
    
    @ViewBuilder
    private func noResultsView() -> some View {
        Text("No results found")
    }
    
    @ViewBuilder
    private func errorView() -> some View {
        Text("Oops, Something went wrong!")
            .foregroundColor(.red)
    }
    
    @ViewBuilder
    private func resultsView(for results: Users) -> some View {
        List {
            ForEach(results.items, id: \.id) { item in
                NavigationLink(
                    destination: NavigationLazyView(
                        RepoListView(
                            viewModel: RepoListViewModel(
                                request: viewModel.request,
                                reposUrl: item.reposUrl,
                                owner: item))))
                {
                    repositoryRow(for: item)
                }
            }
            
            loadMoreView()
        }
    }
    
    @ViewBuilder
    private func repositoryRow(for item: User) -> some View {
        HStack {
            avatarView(for: item.avatarUrl, size: 55)
                .padding(.trailing)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(item.login)
                    .font(.title2)
                
                Text(item.type ?? "")
                    .font(.callout)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Load More -

extension UserSearchView {
    
    @ViewBuilder
    private func loadMoreView() -> some View {
        switch viewModel.loadMore {
            case .notRequested: EmptyView()
            case .isLoading: loadingView(for: .medium)
            case .loaded(let hasResults): if hasResults { loadMoreResultsView() }
            case .failed(_): loadMoreErrorView()
        }
    }
    
    @ViewBuilder
    private func loadMoreResultsView() -> some View {
        loadingView(for: .medium)
            .onAppear {
                viewModel.loadMoreResults()
            }
    }
    
    @ViewBuilder
    private func loadMoreErrorView() -> some View {
        HStack {
            Text("⚠️ Load more failed!")
                .foregroundColor(.red)
            Spacer()
            Button("Retry") {
                viewModel.loadMoreResults()
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.blue)
            .padding()
        }
    }
}

struct UserSearchView_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchView(viewModel: UserSearchViewModel(request: PreviewData.Request))
    }
}
