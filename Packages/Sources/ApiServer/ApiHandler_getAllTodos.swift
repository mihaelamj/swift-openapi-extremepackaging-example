import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllTodos(_ input: SharedApiModels.Operations.GetAllTodos.Input) async throws -> SharedApiModels.Operations.GetAllTodos.Output {
        let limit = input.query.limit ?? 30

        // Mock todos data
        let mockTodos = (1...5).map { id in
            Components.Schemas.Todo(
                id: id,
                todo: "Todo task \(id)",
                completed: id % 2 == 0,
                userId: (id % 5) + 1
            )
        }

        let todosToReturn = Array(mockTodos.prefix(min(limit, mockTodos.count)))

        let response = Operations.GetAllTodos.Output.Ok.Body.JsonPayload(
            todos: todosToReturn,
            total: 100
        )

        return .ok(.init(body: .json(response)))
    }
}
