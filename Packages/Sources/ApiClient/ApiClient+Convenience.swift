import Foundation
import OpenAPIRuntime
import SharedApiModels

// MARK: - Response Wrapper Types

public struct UserListResponse {
    public let users: [Components.Schemas.User]
    public let total: Int
    public let skip: Int
    public let limit: Int
}

public struct PostListResponse {
    public let posts: [Components.Schemas.Post]
    public let total: Int
}

public struct ProductListResponse {
    public let products: [Components.Schemas.Product]
    public let total: Int
}

public struct TodoListResponse {
    public let todos: [Components.Schemas.Todo]
    public let total: Int
}

public struct CommentListResponse {
    public let comments: [Components.Schemas.Comment]
    public let total: Int
}

public struct CartListResponse {
    public let carts: [Components.Schemas.Cart]
    public let total: Int
}

// MARK: - User-Friendly API Layer

public extension ApiClient {

    // MARK: - Authentication

    /// Login with username and password
    func login(username: String, password: String, expiresInMins: Int? = nil) async throws -> Components.Schemas.AuthResponse {
        let credentials = Components.Schemas.LoginRequest(
            username: username,
            password: password,
            expiresInMins: expiresInMins
        )

        let input = Operations.LoginUser.Input(body: .json(credentials))
        let output = try await openAPIClient.loginUser(input)

        switch output {
        case .ok(let response):
            return try response.body.json
        default:
            throw APIError.unexpectedResponse
        }
    }

    // MARK: - Users

    /// Get all users with optional pagination
    func getUsers(limit: Int = 10, skip: Int = 0) async throws -> UserListResponse {
        let query = Operations.GetAllUsers.Input.Query(
            limit: limit,
            skip: skip
        )

        let input = Operations.GetAllUsers.Input(query: query)
        let output = try await openAPIClient.getAllUsers(input)

        switch output {
        case .ok(let response):
            let payload = try response.body.json
            return UserListResponse(
                users: payload.users ?? [],
                total: payload.total ?? 0,
                skip: payload.skip ?? 0,
                limit: payload.limit ?? 0
            )
        default:
            throw APIError.unexpectedResponse
        }
    }

    /// Get a specific user by ID
    func getUser(id: Int) async throws -> Components.Schemas.User {
        let path = Operations.GetUserById.Input.Path(id: id)
        let input = Operations.GetUserById.Input(path: path)
        let output = try await openAPIClient.getUserById(input)

        switch output {
        case .ok(let response):
            return try response.body.json
        case .notFound:
            throw APIError.notFound
        default:
            throw APIError.unexpectedResponse
        }
    }

    /// Create a new user
    func createUser(user: Components.Schemas.User) async throws -> Components.Schemas.User {
        let input = Operations.CreateUser.Input(body: .json(user))
        let output = try await openAPIClient.createUser(input)

        switch output {
        case .created(let response):
            return try response.body.json
        default:
            throw APIError.unexpectedResponse
        }
    }

    // MARK: - Posts

    /// Get all posts with optional pagination
    func getPosts(limit: Int = 10, skip: Int = 0) async throws -> PostListResponse {
        let query = Operations.GetAllPosts.Input.Query(
            limit: limit,
            skip: skip
        )

        let input = Operations.GetAllPosts.Input(query: query)
        let output = try await openAPIClient.getAllPosts(input)

        switch output {
        case .ok(let response):
            let payload = try response.body.json
            return PostListResponse(
                posts: payload.posts ?? [],
                total: payload.total ?? 0
            )
        default:
            throw APIError.unexpectedResponse
        }
    }

    /// Get a specific post by ID
    func getPost(id: Int) async throws -> Components.Schemas.Post {
        let path = Operations.GetPostById.Input.Path(id: id)
        let input = Operations.GetPostById.Input(path: path)
        let output = try await openAPIClient.getPostById(input)

        switch output {
        case .ok(let response):
            return try response.body.json
        default:
            throw APIError.unexpectedResponse
        }
    }

    /// Create a new post
    func createPost(post: Components.Schemas.Post) async throws {
        let input = Operations.CreatePost.Input(body: .json(post))
        let output = try await openAPIClient.createPost(input)

        switch output {
        case .created:
            return
        default:
            throw APIError.unexpectedResponse
        }
    }

    // MARK: - Products

    /// Get all products with optional pagination
    func getProducts(limit: Int = 10, skip: Int = 0) async throws -> ProductListResponse {
        let query = Operations.GetAllProducts.Input.Query(
            limit: limit,
            skip: skip
        )

        let input = Operations.GetAllProducts.Input(query: query)
        let output = try await openAPIClient.getAllProducts(input)

        switch output {
        case .ok(let response):
            let payload = try response.body.json
            return ProductListResponse(
                products: payload.products ?? [],
                total: payload.total ?? 0
            )
        default:
            throw APIError.unexpectedResponse
        }
    }

    /// Get a specific product by ID
    func getProduct(id: Int) async throws -> Components.Schemas.Product {
        let path = Operations.GetProductById.Input.Path(id: id)
        let input = Operations.GetProductById.Input(path: path)
        let output = try await openAPIClient.getProductById(input)

        switch output {
        case .ok(let response):
            return try response.body.json
        default:
            throw APIError.unexpectedResponse
        }
    }

    /// Create a new product
    func createProduct(product: Components.Schemas.Product) async throws {
        let input = Operations.CreateProduct.Input(body: .json(product))
        let output = try await openAPIClient.createProduct(input)

        switch output {
        case .created:
            return
        default:
            throw APIError.unexpectedResponse
        }
    }

    // MARK: - Todos

    /// Get all todos with optional limit
    func getTodos(limit: Int = 10) async throws -> TodoListResponse {
        let query = Operations.GetAllTodos.Input.Query(limit: limit)

        let input = Operations.GetAllTodos.Input(query: query)
        let output = try await openAPIClient.getAllTodos(input)

        switch output {
        case .ok(let response):
            let payload = try response.body.json
            return TodoListResponse(
                todos: payload.todos ?? [],
                total: payload.total ?? 0
            )
        default:
            throw APIError.unexpectedResponse
        }
    }

    /// Get a specific todo by ID
    func getTodo(id: Int) async throws -> Components.Schemas.Todo {
        let path = Operations.GetTodoById.Input.Path(id: id)
        let input = Operations.GetTodoById.Input(path: path)
        let output = try await openAPIClient.getTodoById(input)

        switch output {
        case .ok(let response):
            return try response.body.json
        default:
            throw APIError.unexpectedResponse
        }
    }

    /// Create a new todo
    func createTodo(todo: Components.Schemas.Todo) async throws {
        let input = Operations.CreateTodo.Input(body: .json(todo))
        let output = try await openAPIClient.createTodo(input)

        switch output {
        case .created:
            return
        default:
            throw APIError.unexpectedResponse
        }
    }

    // MARK: - Comments

    /// Get all comments with optional limit
    func getComments(limit: Int = 10) async throws -> CommentListResponse {
        let query = Operations.GetAllComments.Input.Query(limit: limit)

        let input = Operations.GetAllComments.Input(query: query)
        let output = try await openAPIClient.getAllComments(input)

        switch output {
        case .ok(let response):
            let payload = try response.body.json
            return CommentListResponse(
                comments: payload.comments ?? [],
                total: payload.total ?? 0
            )
        default:
            throw APIError.unexpectedResponse
        }
    }

    /// Get a specific comment by ID
    func getComment(id: Int) async throws -> Components.Schemas.Comment {
        let path = Operations.GetCommentById.Input.Path(id: id)
        let input = Operations.GetCommentById.Input(path: path)
        let output = try await openAPIClient.getCommentById(input)

        switch output {
        case .ok(let response):
            return try response.body.json
        default:
            throw APIError.unexpectedResponse
        }
    }

    // MARK: - Carts

    /// Get all carts with optional limit
    func getCarts(limit: Int = 10) async throws -> CartListResponse {
        let query = Operations.GetAllCarts.Input.Query(limit: limit)

        let input = Operations.GetAllCarts.Input(query: query)
        let output = try await openAPIClient.getAllCarts(input)

        switch output {
        case .ok(let response):
            let payload = try response.body.json
            return CartListResponse(
                carts: payload.carts ?? [],
                total: payload.total ?? 0
            )
        default:
            throw APIError.unexpectedResponse
        }
    }

    /// Get a specific cart by ID
    func getCart(id: Int) async throws -> Components.Schemas.Cart {
        let path = Operations.GetCartById.Input.Path(id: id)
        let input = Operations.GetCartById.Input(path: path)
        let output = try await openAPIClient.getCartById(input)

        switch output {
        case .ok(let response):
            return try response.body.json
        default:
            throw APIError.unexpectedResponse
        }
    }
}
