import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func createProduct(_ input: SharedApiModels.Operations.CreateProduct.Input) async throws -> SharedApiModels.Operations.CreateProduct.Output {
        let output = try await client.openAPIClient.createProduct(input)
        return output
    }
}
