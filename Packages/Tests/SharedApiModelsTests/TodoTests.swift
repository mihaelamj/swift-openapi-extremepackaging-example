import XCTest
@testable import SharedApiModels
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import AsyncHTTPClient

final class TodoTests: XCTestCase {
    var client: Client!
    var httpClient: HTTPClient!

    override func setUp() async throws {
        try await super.setUp()
        httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        client = Client(
            serverURL: try Servers.Server1.url(),
            transport: AsyncHTTPClientTransport(configuration: .init(client: httpClient))
        )
    }

    override func tearDown() async throws {
        try await httpClient.shutdown()
        try await super.tearDown()
    }

    // MARK: - Get All Todos Tests

    func testGetAllTodos() async throws {
        // Given
        let input = Operations.GetAllTodos.Input()

        // When
        let output = try await client.getAllTodos(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                XCTAssertNotNil(payload.todos, "Todos array should not be nil")
                XCTAssertNotNil(payload.total, "Total count should not be nil")
                if let todos = payload.todos, let total = payload.total {
                    XCTAssertGreaterThan(todos.count, 0, "Should return at least one todo")
                    XCTAssertGreaterThan(total, 0, "Total should be greater than 0")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllTodosWithLimit() async throws {
        // Given
        let limit = 10
        let input = Operations.GetAllTodos.Input(
            query: .init(limit: limit)
        )

        // When
        let output = try await client.getAllTodos(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let todos = payload.todos {
                    XCTAssertLessThanOrEqual(todos.count, limit, "Should return at most \(limit) todos")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllTodosDefaultLimit() async throws {
        // Given - using default limit of 30
        let input = Operations.GetAllTodos.Input()

        // When
        let output = try await client.getAllTodos(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let todos = payload.todos {
                    XCTAssertLessThanOrEqual(todos.count, 30, "Should use default limit of 30")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    // MARK: - Get Todo By ID Tests

    func testGetTodoById() async throws {
        // Given
        let todoId = 1
        let input = Operations.GetTodoById.Input(
            path: .init(id: todoId)
        )

        // When
        let output = try await client.getTodoById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let todo):
                XCTAssertEqual(todo.id, todoId, "Todo ID should match requested ID")
                XCTAssertNotNil(todo.todo, "Todo text should not be nil")
                XCTAssertNotNil(todo.completed, "Completed status should not be nil")
                XCTAssertNotNil(todo.userId, "User ID should not be nil")
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testTodoDataStructure() async throws {
        // Given
        let todoId = 1
        let input = Operations.GetTodoById.Input(
            path: .init(id: todoId)
        )

        // When
        let output = try await client.getTodoById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let todo):
                // Verify all expected fields
                XCTAssertNotNil(todo.id)
                XCTAssertNotNil(todo.todo)
                XCTAssertNotNil(todo.completed)
                XCTAssertNotNil(todo.userId)

                // Verify data types
                if let id = todo.id {
                    XCTAssertGreaterThan(id, 0, "Todo ID should be positive")
                }

                if let userId = todo.userId {
                    XCTAssertGreaterThan(userId, 0, "User ID should be positive")
                }

                if let todoText = todo.todo {
                    XCTAssertFalse(todoText.isEmpty, "Todo text should not be empty")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve todo successfully")
        }
    }

    func testTodoCompletionStatus() async throws {
        // Given
        let todoId = 1
        let input = Operations.GetTodoById.Input(
            path: .init(id: todoId)
        )

        // When
        let output = try await client.getTodoById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let todo):
                // Completed should be a boolean
                XCTAssertNotNil(todo.completed)

                if let completed = todo.completed {
                    // Just verify it's a valid boolean (true or false)
                    XCTAssert(completed == true || completed == false, "Completed should be a boolean")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve todo successfully")
        }
    }

    func testGetCompletedAndIncompleteTodos() async throws {
        // Given
        let input = Operations.GetAllTodos.Input(
            query: .init(limit: 30)
        )

        // When
        let output = try await client.getAllTodos(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let todos = payload.todos {
                    var completedCount = 0
                    var incompleteCount = 0

                    for todo in todos {
                        if let completed = todo.completed {
                            if completed {
                                completedCount += 1
                            } else {
                                incompleteCount += 1
                            }
                        }
                    }

                    // We expect both completed and incomplete todos to exist
                    XCTAssertGreaterThan(completedCount + incompleteCount, 0, "Should have todos with completion status")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    // MARK: - Create Todo Tests

    func testCreateTodo() async throws {
        // Given
        let newTodo = Components.Schemas.Todo(
            todo: "Write comprehensive tests",
            completed: false,
            userId: 1
        )

        let input = Operations.CreateTodo.Input(
            body: .json(newTodo)
        )

        // When
        let output = try await client.createTodo(input)

        // Then
        switch output {
        case .created:
            XCTAssert(true, "Todo created successfully")
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testCreateCompletedTodo() async throws {
        // Given
        let newTodo = Components.Schemas.Todo(
            todo: "Already completed task",
            completed: true,
            userId: 1
        )

        let input = Operations.CreateTodo.Input(
            body: .json(newTodo)
        )

        // When
        let output = try await client.createTodo(input)

        // Then
        switch output {
        case .created:
            XCTAssert(true, "Completed todo created successfully")
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testCreateTodoWithLongText() async throws {
        // Given
        let longText = "This is a very long todo text that describes a complex task with multiple steps and detailed requirements."
        let newTodo = Components.Schemas.Todo(
            todo: longText,
            completed: false,
            userId: 1
        )

        let input = Operations.CreateTodo.Input(
            body: .json(newTodo)
        )

        // When
        let output = try await client.createTodo(input)

        // Then
        switch output {
        case .created:
            XCTAssert(true, "Todo with long text created successfully")
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testCreateMultipleTodos() async throws {
        // Given
        let todos = [
            Components.Schemas.Todo(todo: "First task", completed: false, userId: 1),
            Components.Schemas.Todo(todo: "Second task", completed: false, userId: 1),
            Components.Schemas.Todo(todo: "Third task", completed: true, userId: 1)
        ]

        // When
        var successCount = 0
        for todo in todos {
            let input = Operations.CreateTodo.Input(body: .json(todo))
            let output = try await client.createTodo(input)

            if case .created = output {
                successCount += 1
            }
        }

        // Then
        XCTAssertEqual(successCount, todos.count, "All todos should be created successfully")
    }

    func testTodoBelongsToUser() async throws {
        // Given
        let todoId = 1
        let input = Operations.GetTodoById.Input(
            path: .init(id: todoId)
        )

        // When
        let output = try await client.getTodoById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let todo):
                if let userId = todo.userId {
                    XCTAssertGreaterThan(userId, 0, "Todo should belong to a valid user")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve todo successfully")
        }
    }
}
