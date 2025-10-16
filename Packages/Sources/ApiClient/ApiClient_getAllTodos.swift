import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllTodos(_ input: SharedApiModels.Operations.GetAllTodos.Input) async throws -> SharedApiModels.Operations.GetAllTodos.Output {
        let output = try await client.openAPIClient.getAllTodos(input)
        return output
    }
}
