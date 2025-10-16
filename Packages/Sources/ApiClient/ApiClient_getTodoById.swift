import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getTodoById(_ input: SharedApiModels.Operations.GetTodoById.Input) async throws -> SharedApiModels.Operations.GetTodoById.Output {
        let output = try await client.openAPIClient.getTodoById(input)
        return output
    }
}
