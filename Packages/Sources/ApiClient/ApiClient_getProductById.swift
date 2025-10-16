import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getProductById(_ input: SharedApiModels.Operations.GetProductById.Input) async throws -> SharedApiModels.Operations.GetProductById.Output {
        let output = try await client.openAPIClient.getProductById(input)
        return output
    }
}
