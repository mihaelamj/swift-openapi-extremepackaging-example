import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllPosts(_ input: SharedApiModels.Operations.GetAllPosts.Input) async throws -> SharedApiModels.Operations.GetAllPosts.Output {
        let limit = input.query.limit ?? 30
        let skip = input.query.skip ?? 0

        // Mock posts data
        let mockPosts = (1...5).map { id in
            Components.Schemas.Post(
                id: id + skip,
                title: "Post \(id + skip) Title",
                body: "This is the body content for post \(id + skip). It contains interesting information.",
                tags: ["tag1", "tag2"],
                reactions: .init(likes: id * 10, dislikes: id),
                views: id * 100,
                userId: ((id + skip) % 10) + 1
            )
        }

        let postsToReturn = Array(mockPosts.prefix(min(limit, mockPosts.count)))

        let response = Operations.GetAllPosts.Output.Ok.Body.JsonPayload(
            posts: postsToReturn,
            total: 150
        )

        return .ok(.init(body: .json(response)))
    }
}
