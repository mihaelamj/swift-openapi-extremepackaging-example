import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getPostById(_ input: SharedApiModels.Operations.GetPostById.Input) async throws -> SharedApiModels.Operations.GetPostById.Output {
        let postId = input.path.id

        // Mock post data
        let post = Components.Schemas.Post(
            id: postId,
            title: "Post \(postId) Title",
            body: "This is the detailed body content for post \(postId). It contains interesting information and insights.",
            tags: ["technology", "tutorial", "swift"],
            reactions: .init(likes: postId * 15, dislikes: postId * 2),
            views: postId * 250,
            userId: (postId % 10) + 1
        )

        return .ok(.init(body: .json(post)))
    }
}
