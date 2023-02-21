//
//  RepoDetailView.swift
//  GitHub Watcher
//
//  Created by Sergey Slobodenyuk on 2023-02-19.
//

import SwiftUI
import Charts

struct RepoDetailView: View {
    
    @ObservedObject private(set) var viewModel: RepoDetailViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            contentView()
                .onAppear {
                    viewModel.fetchContributors()
                    viewModel.fetchLanguages()
                }
        }
        .navigationTitle("Repository")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack {
                Text(viewModel.repo.name)
                    .fontWeight(.bold)
                Text(viewModel.repo.private ? "Private" : "Public")
                    .font(.caption)
                    .padding(.horizontal, 7)
                    .background()
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(.gray, lineWidth: 0.7)
                    )

            }
            .padding(.top)
            
            Text(viewModel.repo.description ?? "No description")
                .font(.title3)
            
            if let createdDate = viewModel.repo.createdAt {
                HStack {
                    Text("Created:")
                        .fontWeight(.bold)
                    Text(createdDate.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.footnote)
            }
            
            Divider()

            ownerRow(title: "Owner")
            
            Divider()
            
            contributorsRow(title: "Contributors",
                     detail: viewModel.contributors)

            Divider()

            languagesRow(title: "Languages",
                     detail: viewModel.languages)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func infoRow(title: String, detail: String) -> some View {
        HStack {
            Text(title)
                .font(.title3)
            Spacer()
            Text(detail)
        }
    }
    
    @ViewBuilder
    private func ownerRow(title: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            userView(for: viewModel.repo.owner ?? User(id: 0, login: "Unknown", avatarUrl: "", type: nil, reposUrl: ""))
        }
    }
    
    @ViewBuilder
    private func contributorsRow(title: String, detail: Loadable<Contributors>) -> some View {
        VStack (alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                switch detail {
                    case .loaded(let results): loadedContributorCountView(for: results)
                    default: emptyView()
                }
            }
            switch detail {
                case .notRequested: Text("Will bee updated...").font(.callout)
                case .isLoading: ActivityIndicatorView(style: .medium)
                case .loaded(let results): loadedContributorsView(for: results)
                case .failed: errorView()
            }
        }
    }
    
    @ViewBuilder
    private func languagesRow(title: String, detail: Loadable<Languages>) -> some View {
        VStack (alignment: .leading) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            switch detail {
                case .notRequested: Text("Will bee updated...").font(.callout)
                case .isLoading: ActivityIndicatorView(style: .medium)
                case .loaded(let results): loadedLanguagesView(for: results)
                case .failed: errorView()
            }
        }
    }
    
    @ViewBuilder
    private func emptyView() -> some View {
        Group {}
    }
    
    @ViewBuilder
    private func errorView() -> some View {
        Text("Unexpected error!")
            .foregroundColor(.red)
    }
    
    @ViewBuilder
    private func noResultsView() -> some View {
        Text("No results found")
    }
    
    @ViewBuilder
    private func loadedContributorCountView(for results: Contributors) -> some View {
        Text("\(results.count)")
            .font(.callout)
            .frame(width: 25, height: 25)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
    }
    
    @ViewBuilder
    private func loadedContributorsView(for results: Contributors) -> some View {
        if results.isEmpty {
            noResultsView()
        } else {
            contributorsResultsView(for: results)
        }
    }
    
    @ViewBuilder
    private func contributorsResultsView(for detail: Contributors) -> some View {
        ForEach(detail, id: \.id) { item in
            userView(for: item)
        }
    }
    
    @ViewBuilder
    private func userView(for user: User) -> some View {
        HStack {
            if let url = user.avatarUrl {
                avatarView(for: url, size: 30)
            }
            Text(user.login)
                .font(.callout)
                .fontWeight(.bold)
        }
    }

    @ViewBuilder
    private func loadedLanguagesView(for results: Languages) -> some View {
        if results.isEmpty {
            noResultsView()
        } else {
            languagesResultsView(for: results)
        }
    }
    
    @ViewBuilder
    private func languagesResultsView(for detail: Languages) -> some View {
        VStack {
            Chart(detail) { item in
                BarMark(
                    x: .value("Amount", item.value)
                )
                .foregroundStyle(item.color)
            }
            .chartXAxis(.hidden)
            .chartLegend(.hidden)
            .frame(height: 10)
            .clipShape(Capsule())
            .padding(.bottom, 5)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 250), spacing: 10, alignment: .leading)]) {
                ForEach(detail.sorted { $0.value > $1.value }, id: \.name) { item in
                    HStack {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(item.color)
                        Text(item.name)
                            .font(.footnote)
                            .fontWeight(.bold)
                        Text(String(format: "%.1f", item.value) + " %")
                            .font(.footnote)
                            .opacity(0.7)
                    }
                }
            }
        }
    }
}

struct RepoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RepoDetailView(viewModel: RepoDetailViewModel(request: PreviewData.Request, repo: PreviewData.SingleRepo))
    }
}
