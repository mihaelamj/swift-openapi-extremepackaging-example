import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func createProduct(_ input: SharedApiModels.Operations.CreateProduct.Input) async throws -> SharedApiModels.Operations.CreateProduct.Output {
        // Extract product from request body
        switch input.body {
        case .json:
            // Product created successfully
            return .created(.init())
        }
    }
}
