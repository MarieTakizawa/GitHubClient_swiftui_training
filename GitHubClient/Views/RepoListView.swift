import SwiftUI

struct RepoListView: View {
    
    @State private var store = ReposStore()
    
    var body: some View {
        NavigationStack {
            Group {
                if store.error != nil {
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
                } else {
                    if store.isLoading {
                        ProgressView("loading...")
                    } else {
                        List(store.repos) { repo in
                            NavigationLink(value: repo) {
                                RepoRow(repo: repo)
                            }
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
    private(set) var repos = [Repo]()
    private(set) var error: Error? = nil
    private(set) var isLoading: Bool = false
    
    func loadRepos() async {
        isLoading = true
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

//            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                            throw URLError(.badServerResponse)
//                        }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            repos = try! decoder.decode([Repo].self, from: data)
        } catch {
            self.error = error
        }
        isLoading = false
    }
}

#Preview {
    RepoListView()
}
