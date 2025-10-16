import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getPostById(_ input: SharedApiModels.Operations.GetPostById.Input) async throws -> SharedApiModels.Operations.GetPostById.Output {
        let output = try await client.openAPIClient.getPostById(input)
        return output
    }
}
