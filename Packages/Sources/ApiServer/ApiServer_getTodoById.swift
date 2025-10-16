import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getTodoById(_ input: SharedApiModels.Operations.GetTodoById.Input) async throws -> SharedApiModels.Operations.GetTodoById.Output {
        let todoId = input.path.id

        // Mock todo data
        let todo = Components.Schemas.Todo(
            id: todoId,
            todo: "Todo task \(todoId) - Complete important work",
            completed: todoId % 3 == 0,
            userId: (todoId % 10) + 1
        )

        return .ok(.init(body: .json(todo)))
    }
}
