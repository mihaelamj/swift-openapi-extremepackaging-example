import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllPosts(_ input: SharedApiModels.Operations.GetAllPosts.Input) async throws -> SharedApiModels.Operations.GetAllPosts.Output {
        let output = try await client.openAPIClient.getAllPosts(input)
        return output
    }
}
