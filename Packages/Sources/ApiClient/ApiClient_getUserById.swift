import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getUserById(_ input: SharedApiModels.Operations.GetUserById.Input) async throws -> SharedApiModels.Operations.GetUserById.Output {
        let output = try await client.openAPIClient.getUserById(input)
        return output
    }
}
