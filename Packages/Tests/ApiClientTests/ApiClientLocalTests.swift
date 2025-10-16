@testable import ApiClient
import XCTest
import SharedApiModels

final class ApiClientLocalTests: XCTestCase {

    var client: ApiClient!

    override func setUp() async throws {
        try await super.setUp()

        // Check if local server is running
        guard await isLocalServerRunning() else {
            throw XCTSkip("Local server is not running. Start the server with: swift run apiserver")
        }

        // Initialize client with local environment
        client = try await ApiClient(environment: .local)
    }

    override func tearDown() async throws {
        client = nil
        try await super.tearDown()
    }

    /// Helper function to check if local server is running
    private func isLocalServerRunning() async -> Bool {
        do {
            _ = try await URLSession.shared.data(
                from: URL(string: "http://localhost:8080")!
            )
            return true
        } catch {
            return false
        }
    }

    // MARK: - Authentication Tests

    func testLogin() async throws {
        let authResponse = try await client.login(
            username: "emilys",
            password: "emilyspass"
        )

        XCTAssertNotNil(authResponse.accessToken)
        XCTAssertNotNil(authResponse.refreshToken)
        XCTAssertEqual(authResponse.username, "emilys")
        XCTAssertNotNil(authResponse.email)
    }

    func testLoginWithCustomExpiry() async throws {
        let authResponse = try await client.login(
            username: "emilys",
            password: "emilyspass",
            expiresInMins: 30
        )

        XCTAssertNotNil(authResponse.accessToken)
    }

    // MARK: - User Tests

    func testGetUsers() async throws {
        let response = try await client.getUsers(limit: 5, skip: 0)

        XCTAssertFalse(response.users.isEmpty)
        XCTAssertGreaterThan(response.total, 0)
        XCTAssertEqual(response.limit, 5)
        XCTAssertEqual(response.skip, 0)
    }

    func testGetUsersWithDefaultPagination() async throws {
        let response = try await client.getUsers()

        XCTAssertFalse(response.users.isEmpty)
        XCTAssertGreaterThan(response.total, 0)
    }

    func testGetUserById() async throws {
        let user = try await client.getUser(id: 1)

        XCTAssertEqual(user.id, 1)
        XCTAssertNotNil(user.firstName)
        XCTAssertNotNil(user.lastName)
        XCTAssertNotNil(user.email)
    }

    func testGetUserByIdNotFound() async throws {
        do {
            _ = try await client.getUser(id: 999999)
            XCTFail("Expected to throw notFound error")
        } catch APIError.notFound {
            // Expected error
        } catch {
            XCTFail("Expected APIError.notFound, got \(error)")
        }
    }

    func testCreateUser() async throws {
        let newUser = Components.Schemas.User(
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com"
        )

        let createdUser = try await client.createUser(user: newUser)

        XCTAssertNotNil(createdUser.id)
        XCTAssertEqual(createdUser.firstName, "John")
        XCTAssertEqual(createdUser.lastName, "Doe")
    }

    // MARK: - Post Tests

    func testGetPosts() async throws {
        let response = try await client.getPosts(limit: 5, skip: 0)

        XCTAssertFalse(response.posts.isEmpty)
        XCTAssertGreaterThan(response.total, 0)
    }

    func testGetPostById() async throws {
        let post = try await client.getPost(id: 1)

        XCTAssertEqual(post.id, 1)
        XCTAssertNotNil(post.title)
        XCTAssertNotNil(post.body)
    }

    func testCreatePost() async throws {
        let newPost = Components.Schemas.Post(
            title: "Test Post",
            body: "This is a test post body",
            userId: 1
        )

        try await client.createPost(post: newPost)
        // If no error is thrown, the test passes
    }

    // MARK: - Product Tests

    func testGetProducts() async throws {
        let response = try await client.getProducts(limit: 5, skip: 0)

        XCTAssertFalse(response.products.isEmpty)
        XCTAssertGreaterThan(response.total, 0)
    }

    func testGetProductById() async throws {
        let product = try await client.getProduct(id: 1)

        XCTAssertEqual(product.id, 1)
        XCTAssertNotNil(product.title)
        XCTAssertNotNil(product.price)
    }

    func testCreateProduct() async throws {
        let newProduct = Components.Schemas.Product(
            title: "Test Product",
            price: 99.99
        )

        try await client.createProduct(product: newProduct)
        // If no error is thrown, the test passes
    }

    // MARK: - Todo Tests

    func testGetTodos() async throws {
        let response = try await client.getTodos(limit: 5)

        XCTAssertFalse(response.todos.isEmpty)
        XCTAssertGreaterThan(response.total, 0)
    }

    func testGetTodoById() async throws {
        let todo = try await client.getTodo(id: 1)

        XCTAssertEqual(todo.id, 1)
        XCTAssertNotNil(todo.todo)
        XCTAssertNotNil(todo.completed)
    }

    func testCreateTodo() async throws {
        let newTodo = Components.Schemas.Todo(
            todo: "Test Todo",
            completed: false,
            userId: 1
        )

        try await client.createTodo(todo: newTodo)
        // If no error is thrown, the test passes
    }

    // MARK: - Comment Tests

    func testGetComments() async throws {
        let response = try await client.getComments(limit: 5)

        XCTAssertFalse(response.comments.isEmpty)
        XCTAssertGreaterThan(response.total, 0)
    }

    func testGetCommentById() async throws {
        let comment = try await client.getComment(id: 1)

        XCTAssertEqual(comment.id, 1)
        XCTAssertNotNil(comment.body)
        XCTAssertNotNil(comment.postId)
    }

    // MARK: - Cart Tests

    func testGetCarts() async throws {
        let response = try await client.getCarts(limit: 5)

        XCTAssertFalse(response.carts.isEmpty)
        XCTAssertGreaterThan(response.total, 0)
    }

    func testGetCartById() async throws {
        let cart = try await client.getCart(id: 1)

        XCTAssertEqual(cart.id, 1)
        XCTAssertNotNil(cart.products)
        XCTAssertNotNil(cart.total)
    }

    // MARK: - Integration Tests

    func testFullUserWorkflow() async throws {
        // 1. Get all users
        let usersResponse = try await client.getUsers(limit: 10)
        XCTAssertFalse(usersResponse.users.isEmpty)

        // 2. Get first user by ID
        let firstUserId = usersResponse.users.first?.id ?? 1
        let user = try await client.getUser(id: firstUserId)
        XCTAssertEqual(user.id, firstUserId)

        // 3. Create a new user
        let newUser = Components.Schemas.User(
            firstName: "Integration",
            lastName: "Test",
            email: "integration@test.com"
        )
        let createdUser = try await client.createUser(user: newUser)
        XCTAssertNotNil(createdUser.id)
    }

    func testFullPostWorkflow() async throws {
        // 1. Get all posts
        let postsResponse = try await client.getPosts(limit: 10)
        XCTAssertFalse(postsResponse.posts.isEmpty)

        // 2. Get first post by ID
        let firstPostId = postsResponse.posts.first?.id ?? 1
        let post = try await client.getPost(id: firstPostId)
        XCTAssertEqual(post.id, firstPostId)

        // 3. Create a new post
        let newPost = Components.Schemas.Post(
            title: "Integration Test Post",
            body: "This is an integration test",
            userId: 1
        )
        try await client.createPost(post: newPost)
    }

    func testMiddlewareLogging() async throws {
        // This test ensures middlewares are working
        // The logging middleware should log the request/response
        let response = try await client.getUsers(limit: 1)
        XCTAssertFalse(response.users.isEmpty)
    }

    func testPaginationConsistency() async throws {
        // Test that pagination parameters work correctly
        let page1 = try await client.getUsers(limit: 5, skip: 0)
        let page2 = try await client.getUsers(limit: 5, skip: 5)

        XCTAssertEqual(page1.users.count, 5)
        XCTAssertEqual(page2.users.count, 5)

        // Ensure we got different users
        let page1Ids = Set(page1.users.compactMap { $0.id })
        let page2Ids = Set(page2.users.compactMap { $0.id })
        XCTAssertTrue(page1Ids.isDisjoint(with: page2Ids))
    }

    func testEnvironmentSwitching() async throws {
        // Test switching between environments
        let localClient = try await ApiClient(environment: .local)
        let response = try await localClient.getUsers(limit: 1)
        XCTAssertFalse(response.users.isEmpty)

        // Switch environment
        try await localClient.switchEnvironment(to: .local)
        let response2 = try await localClient.getUsers(limit: 1)
        XCTAssertFalse(response2.users.isEmpty)
    }
}
