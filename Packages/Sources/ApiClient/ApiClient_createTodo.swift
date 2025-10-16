import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func createTodo(_ input: SharedApiModels.Operations.CreateTodo.Input) async throws -> SharedApiModels.Operations.CreateTodo.Output {
        let output = try await client.openAPIClient.createTodo(input)
        return output
    }
}
