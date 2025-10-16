import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func createPost(_ input: SharedApiModels.Operations.CreatePost.Input) async throws -> SharedApiModels.Operations.CreatePost.Output {
        let output = try await client.openAPIClient.createPost(input)
        return output
    }
}
