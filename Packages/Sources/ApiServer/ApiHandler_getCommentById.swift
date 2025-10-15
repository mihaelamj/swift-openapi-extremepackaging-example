import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getCommentById(_ input: SharedApiModels.Operations.GetCommentById.Input) async throws -> SharedApiModels.Operations.GetCommentById.Output {
        let commentId = input.path.id

        // Mock comment data
        let comment = Components.Schemas.Comment(
            id: commentId,
            body: "This is a detailed comment \(commentId) with thoughtful feedback and analysis of the post content.",
            postId: (commentId % 20) + 1,
            likes: commentId * 3,
            user: .init(
                id: (commentId % 10) + 1,
                username: "user\(commentId)",
                fullName: "User \(commentId) Full Name"
            )
        )

        return .ok(.init(body: .json(comment)))
    }
}
