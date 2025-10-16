import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func loginUser(_ input: SharedApiModels.Operations.LoginUser.Input) async throws -> SharedApiModels.Operations.LoginUser.Output {
        let output = try await client.openAPIClient.loginUser(input)
        return output
    }
}
