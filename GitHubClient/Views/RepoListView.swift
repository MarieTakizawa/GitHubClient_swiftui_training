import SwiftUI

struct RepoListView: View {
    @State var count = 0
    @State var isShownSheetView = false

    @State var store: ReposStore
    var body: some View {
        NavigationStack {
            Group {
                switch store.state {
                case .loading:
                    ProgressView("loading...")
                case let .loaded(repos):
                    List(repos) { repo in
                        NavigationLink(value: repo) {
                            RepoRow(repo: repo)
                        }
                    }
                case .failed:
                    VStack {
                        Text("Failed to load repositories")
                        Button(
                            action: {
                                Task {
                                    await store.send(.onRetryButtonTapped)
                                }
                            },
                            label: {
                                Text("Retry")
                            }
                        )
                        .padding()
                    }
                }
            }
            .navigationTitle("Repositories")
            .navigationDestination(for: Repo.self) { repo in
                RepoDetailView(repo: repo)
            }
        }
        .task {
            await store.send(.onAppear)
        }

        VStack {
            HStack {
                Button("-") {
                    count -= 1
                }
                Text("Counter: \(count)")
                Button("+") {
                    count += 1
                }
            }
            .padding()

            Button("show sheetView") {
                isShownSheetView = true
            }
        }
        .padding()
        .font(.title)
        .sheet(isPresented: $isShownSheetView, content: {
            sheetView(sheetCount: $count)
        })
    }
}

struct sheetView: View {
    @Binding var sheetCount: Int
    var body: some View {
        Button("+10") {
            sheetCount += 10
        }
        .font(.title)
    }
}

#Preview("Default") {
    RepoListView(
        store: ReposStore(
            repoAPIClient: MockRepoAPIClient(
                getRepos: { [.mock1, .mock2, .mock5] }
            )
        )
    )
}

#Preview("Loading") {
    RepoListView(
        store: ReposStore(
            repoAPIClient: MockRepoAPIClient(
                getRepos: {
                    while true {
                        try await Task.sleep(until: .now + .seconds(1))
                    }
                }
            )
        )
    )
}

#Preview("Error") {
    RepoListView(
        store: ReposStore(
            repoAPIClient: MockRepoAPIClient(
                getRepos: { throw DummyError() }
            )
        )
    )
}
