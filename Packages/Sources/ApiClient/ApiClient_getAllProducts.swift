import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllProducts(_ input: SharedApiModels.Operations.GetAllProducts.Input) async throws -> SharedApiModels.Operations.GetAllProducts.Output {
        let output = try await client.openAPIClient.getAllProducts(input)
        return output
    }
}
