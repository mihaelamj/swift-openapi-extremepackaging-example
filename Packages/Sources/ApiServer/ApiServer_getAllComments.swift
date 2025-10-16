import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllComments(_ input: SharedApiModels.Operations.GetAllComments.Input) async throws -> SharedApiModels.Operations.GetAllComments.Output {
        let limit = input.query.limit ?? 30

        // Mock comments data
        let mockComments = (1...5).map { id in
            Components.Schemas.Comment(
                id: id,
                body: "This is comment \(id) with some interesting feedback and thoughts.",
                postId: (id % 10) + 1,
                likes: id * 5,
                user: .init(
                    id: (id % 5) + 1,
                    username: "user\(id)",
                    fullName: "User \(id) Name"
                )
            )
        }

        let commentsToReturn = Array(mockComments.prefix(min(limit, mockComments.count)))

        let response = Operations.GetAllComments.Output.Ok.Body.JsonPayload(
            comments: commentsToReturn,
            total: 300
        )

        return .ok(.init(body: .json(response)))
    }
}
