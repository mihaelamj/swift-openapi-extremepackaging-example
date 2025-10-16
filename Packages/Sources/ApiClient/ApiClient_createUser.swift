import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func createUser(_ input: SharedApiModels.Operations.CreateUser.Input) async throws -> SharedApiModels.Operations.CreateUser.Output {
        let output = try await client.openAPIClient.createUser(input)
        return output
    }
}
