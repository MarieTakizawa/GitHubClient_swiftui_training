import Foundation

struct MockRepoAPIClient: RepoApiClientProtocol {
    var getRepos: () async throws -> [Repo]
    
    func getRepos() async throws -> [Repo] {
        try await getRepos()
    }
}
