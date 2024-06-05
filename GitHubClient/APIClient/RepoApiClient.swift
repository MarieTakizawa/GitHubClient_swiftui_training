import Foundation

protocol RepoApiClientProtocol {
    func getRepos() async throws -> [Repo]
}

struct RepoAPIClient: RepoApiClientProtocol {
    func getRepos() async throws -> [Repo] {
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept" : "application/vnd.github+json"
        ]
        
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        
        let (data, response) = try! await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode([Repo].self, from: data)
    }
}
