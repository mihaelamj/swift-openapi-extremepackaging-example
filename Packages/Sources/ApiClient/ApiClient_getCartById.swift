import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getCartById(_ input: SharedApiModels.Operations.GetCartById.Input) async throws -> SharedApiModels.Operations.GetCartById.Output {
        let output = try await client.openAPIClient.getCartById(input)
        return output
    }
}
