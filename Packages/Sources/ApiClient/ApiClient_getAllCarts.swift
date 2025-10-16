import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllCarts(_ input: SharedApiModels.Operations.GetAllCarts.Input) async throws -> SharedApiModels.Operations.GetAllCarts.Output {
        let output = try await client.openAPIClient.getAllCarts(input)
        return output
    }
}
