import SwiftUI

struct RepoListView: View {
    
    @State private var store = ReposStore()
    
    var body: some View {
        NavigationStack {
            if store.repos.isEmpty {
                ProgressView("loading")
            } else {
                List(store.repos) { repo in
                    NavigationLink(value: repo) {
                        RepoRow(repo: repo)
                    }
                }
                .navigationTitle("Repositories")
                .navigationDestination(for: Repo.self) { repo in
                    RepoDetailView(repo: repo)
                }
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
    
    func loadRepos() async {
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept" : "application/vnd.github+json"
        ]
        
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        
        let (data, _) = try! await URLSession.shared.data(for: urlRequest)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        repos = try! decoder.decode([Repo].self, from: data)
    }
}

#Preview {
    RepoListView()
}
