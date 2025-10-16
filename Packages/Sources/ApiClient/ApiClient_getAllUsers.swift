import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllUsers(_ input: SharedApiModels.Operations.GetAllUsers.Input) async throws -> SharedApiModels.Operations.GetAllUsers.Output {
        let output = try await client.openAPIClient.getAllUsers(input)
        return output
    }
}
