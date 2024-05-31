import SwiftUI

struct RepoListView: View {
    @State var store = ReposStore()
    
    var body: some View {
        NavigationStack {
            Group {
                switch store.state {
                case .loading:
                    ProgressView("loading...")
                case .failed:
                    VStack {
                        Text("Failed to load repositories")
                        Button(
                            action: {
                                Task {
                                    await store.loadRepos()
                                }
                            },
                            label: {
                                Text("Retry")
                            }
                        )
                        .padding()
                    }
                case let .loaded(repos):
                    List(repos) { repo in
                        NavigationLink(value: repo) {
                            RepoRow(repo: repo)
                        }
                    }
                }
            }
            .navigationTitle("Repositories")
            .navigationDestination(for: Repo.self) { repo in
                RepoDetailView(repo: repo)
            }
        }
        .task {
            await store.loadRepos()
        }
    }
}

@Observable
class ReposStore {
    private(set) var state: Stateful<[Repo]> = .loading
    
    func loadRepos() async {
        state = .loading
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept" : "application/vnd.github+json"
        ]
        
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        
        do {
            let (data, response) = try! await URLSession.shared.data(for: urlRequest)
            try! await Task.sleep(nanoseconds: 1_000_000_000)

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                            throw URLError(.badServerResponse)
                        }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let repos = try! decoder.decode([Repo].self, from: data)
            state = .loaded(repos)
        } catch {
            self.state = .failed(error)
        }
    }
}

#Preview {
    RepoListView()
}
