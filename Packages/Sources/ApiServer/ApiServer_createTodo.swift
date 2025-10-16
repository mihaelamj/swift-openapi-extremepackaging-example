import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func createTodo(_ input: SharedApiModels.Operations.CreateTodo.Input) async throws -> SharedApiModels.Operations.CreateTodo.Output {
        // Extract todo from request body
        switch input.body {
        case .json:
            // Todo created successfully
            return .created(.init())
        }
    }
}
