import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getCommentById(_ input: SharedApiModels.Operations.GetCommentById.Input) async throws -> SharedApiModels.Operations.GetCommentById.Output {
        let output = try await client.openAPIClient.getCommentById(input)
        return output
    }
}
