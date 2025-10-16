@testable import ApiClient
import XCTest
import SharedApiModels

final class ApiClientProductionTests: XCTestCase {

    var client: ApiClient!

    override func setUp() async throws {
        try await super.setUp()

        // Initialize client with production environment (DummyJSON API)
        client = try await ApiClient(environment: .production)
    }

    override func tearDown() async throws {
        client = nil
        try await super.tearDown()
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
        XCTAssertNotNil(authResponse.firstName)
        XCTAssertNotNil(authResponse.lastName)
    }

    func testLoginWithCustomExpiry() async throws {
        let authResponse = try await client.login(
            username: "emilys",
            password: "emilyspass",
            expiresInMins: 30
        )

        XCTAssertNotNil(authResponse.accessToken)
        XCTAssertNotNil(authResponse.refreshToken)
    }

    // MARK: - User Tests

    func testGetUsers() async throws {
        let response = try await client.getUsers(limit: 5, skip: 0)

        XCTAssertFalse(response.users.isEmpty)
        XCTAssertGreaterThan(response.total, 0)
        XCTAssertEqual(response.limit, 5)
        XCTAssertEqual(response.skip, 0)

        // Verify user structure
        if let firstUser = response.users.first {
            XCTAssertNotNil(firstUser.id)
            XCTAssertNotNil(firstUser.firstName)
            XCTAssertNotNil(firstUser.email)
        }
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
        XCTAssertNotNil(user.username)
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

    // MARK: - Post Tests

    func testGetPosts() async throws {
        let response = try await client.getPosts(limit: 5, skip: 0)

        XCTAssertFalse(response.posts.isEmpty)
        XCTAssertGreaterThan(response.total, 0)

        // Verify post structure
        if let firstPost = response.posts.first {
            XCTAssertNotNil(firstPost.id)
            XCTAssertNotNil(firstPost.title)
            XCTAssertNotNil(firstPost.body)
            XCTAssertNotNil(firstPost.userId)
        }
    }

    func testGetPostById() async throws {
        let post = try await client.getPost(id: 1)

        XCTAssertEqual(post.id, 1)
        XCTAssertNotNil(post.title)
        XCTAssertNotNil(post.body)
        XCTAssertNotNil(post.userId)
    }

    func testGetPostsPagination() async throws {
        let page1 = try await client.getPosts(limit: 10, skip: 0)
        let page2 = try await client.getPosts(limit: 10, skip: 10)

        XCTAssertEqual(page1.posts.count, 10)
        XCTAssertEqual(page2.posts.count, 10)

        // Ensure different posts on different pages
        let page1Ids = Set(page1.posts.compactMap { $0.id })
        let page2Ids = Set(page2.posts.compactMap { $0.id })
        XCTAssertTrue(page1Ids.isDisjoint(with: page2Ids))
    }

    // MARK: - Product Tests

    func testGetProducts() async throws {
        let response = try await client.getProducts(limit: 5, skip: 0)

        XCTAssertFalse(response.products.isEmpty)
        XCTAssertGreaterThan(response.total, 0)

        // Verify product structure
        if let firstProduct = response.products.first {
            XCTAssertNotNil(firstProduct.id)
            XCTAssertNotNil(firstProduct.title)
            XCTAssertNotNil(firstProduct.price)
        }
    }

    func testGetProductById() async throws {
        let product = try await client.getProduct(id: 1)

        XCTAssertEqual(product.id, 1)
        XCTAssertNotNil(product.title)
        XCTAssertNotNil(product.description)
        XCTAssertNotNil(product.price)
        XCTAssertNotNil(product.category)
        XCTAssertNotNil(product.rating)
    }

    func testGetProductsPagination() async throws {
        let page1 = try await client.getProducts(limit: 10, skip: 0)
        let page2 = try await client.getProducts(limit: 10, skip: 10)

        XCTAssertEqual(page1.products.count, 10)
        XCTAssertEqual(page2.products.count, 10)
    }

    // MARK: - Todo Tests

    func testGetTodos() async throws {
        let response = try await client.getTodos(limit: 5)

        XCTAssertFalse(response.todos.isEmpty)
        XCTAssertGreaterThan(response.total, 0)

        // Verify todo structure
        if let firstTodo = response.todos.first {
            XCTAssertNotNil(firstTodo.id)
            XCTAssertNotNil(firstTodo.todo)
            XCTAssertNotNil(firstTodo.completed)
            XCTAssertNotNil(firstTodo.userId)
        }
    }

    func testGetTodoById() async throws {
        let todo = try await client.getTodo(id: 1)

        XCTAssertEqual(todo.id, 1)
        XCTAssertNotNil(todo.todo)
        XCTAssertNotNil(todo.completed)
        XCTAssertNotNil(todo.userId)
    }

    // MARK: - Comment Tests

    func testGetComments() async throws {
        let response = try await client.getComments(limit: 5)

        XCTAssertFalse(response.comments.isEmpty)
        XCTAssertGreaterThan(response.total, 0)

        // Verify comment structure
        if let firstComment = response.comments.first {
            XCTAssertNotNil(firstComment.id)
            XCTAssertNotNil(firstComment.body)
            XCTAssertNotNil(firstComment.postId)
        }
    }

    func testGetCommentById() async throws {
        let comment = try await client.getComment(id: 1)

        XCTAssertEqual(comment.id, 1)
        XCTAssertNotNil(comment.body)
        XCTAssertNotNil(comment.postId)
        XCTAssertNotNil(comment.likes)
    }

    // MARK: - Cart Tests

    func testGetCarts() async throws {
        let response = try await client.getCarts(limit: 5)

        XCTAssertFalse(response.carts.isEmpty)
        XCTAssertGreaterThan(response.total, 0)

        // Verify cart structure
        if let firstCart = response.carts.first {
            XCTAssertNotNil(firstCart.id)
            XCTAssertNotNil(firstCart.products)
            XCTAssertNotNil(firstCart.total)
            XCTAssertNotNil(firstCart.userId)
        }
    }

    func testGetCartById() async throws {
        let cart = try await client.getCart(id: 1)

        XCTAssertEqual(cart.id, 1)
        XCTAssertNotNil(cart.products)
        XCTAssertNotNil(cart.total)
        XCTAssertNotNil(cart.userId)

        // Verify products in cart
        XCTAssertFalse(cart.products?.isEmpty ?? true)
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

        // Verify user has expected data from DummyJSON
        XCTAssertNotNil(user.email)
        XCTAssertNotNil(user.username)
    }

    func testFullPostWorkflow() async throws {
        // 1. Get all posts
        let postsResponse = try await client.getPosts(limit: 10)
        XCTAssertFalse(postsResponse.posts.isEmpty)

        // 2. Get first post by ID
        let firstPostId = postsResponse.posts.first?.id ?? 1
        let post = try await client.getPost(id: firstPostId)
        XCTAssertEqual(post.id, firstPostId)

        // Verify post has expected data
        XCTAssertNotNil(post.title)
        XCTAssertNotNil(post.body)
    }

    func testFullProductWorkflow() async throws {
        // 1. Get all products
        let productsResponse = try await client.getProducts(limit: 10)
        XCTAssertFalse(productsResponse.products.isEmpty)

        // 2. Get first product by ID
        let firstProductId = productsResponse.products.first?.id ?? 1
        let product = try await client.getProduct(id: firstProductId)
        XCTAssertEqual(product.id, firstProductId)

        // Verify product has expected data
        XCTAssertNotNil(product.title)
        XCTAssertNotNil(product.price)
        XCTAssertNotNil(product.category)
    }

    func testMiddlewareLogging() async throws {
        // This test ensures middlewares are working
        // The logging middleware should log the request/response to DummyJSON API
        let response = try await client.getUsers(limit: 1)
        XCTAssertFalse(response.users.isEmpty)
    }

    func testMultipleRequestsInSequence() async throws {
        // Test that multiple sequential requests work correctly
        let users = try await client.getUsers(limit: 5)
        XCTAssertFalse(users.users.isEmpty)

        let posts = try await client.getPosts(limit: 5)
        XCTAssertFalse(posts.posts.isEmpty)

        let products = try await client.getProducts(limit: 5)
        XCTAssertFalse(products.products.isEmpty)

        let todos = try await client.getTodos(limit: 5)
        XCTAssertFalse(todos.todos.isEmpty)

        let comments = try await client.getComments(limit: 5)
        XCTAssertFalse(comments.comments.isEmpty)

        let carts = try await client.getCarts(limit: 5)
        XCTAssertFalse(carts.carts.isEmpty)
    }

    func testEnvironmentSwitching() async throws {
        // Test that we can switch between environments
        let productionClient = try await ApiClient(environment: .production)
        let response1 = try await productionClient.getUsers(limit: 1)
        XCTAssertFalse(response1.users.isEmpty)

        // Switch to local (will fail if local server not running, which is expected)
        try await productionClient.switchEnvironment(to: .local)

        // Switch back to production
        try await productionClient.switchEnvironment(to: .production)
        let response2 = try await productionClient.getUsers(limit: 1)
        XCTAssertFalse(response2.users.isEmpty)
    }

    func testConcurrentRequests() async throws {
        // Test that multiple concurrent requests work correctly
        // Note: Since client is an actor, we need to await each call separately
        let usersResult = try await client.getUsers(limit: 5)
        let postsResult = try await client.getPosts(limit: 5)
        let productsResult = try await client.getProducts(limit: 5)

        XCTAssertFalse(usersResult.users.isEmpty)
        XCTAssertFalse(postsResult.posts.isEmpty)
        XCTAssertFalse(productsResult.products.isEmpty)
    }

    // MARK: - Authentication Token Tests

    func testAuthenticatedRequest() async throws {
        // 1. Login to get token
        let authResponse = try await client.login(
            username: "emilys",
            password: "emilyspass"
        )

        XCTAssertNotNil(authResponse.accessToken)
        let token = authResponse.accessToken

        // 2. Set token for authenticated requests
        await ApiClient.setToken(token)

        // 3. Make an authenticated request
        // Note: DummyJSON doesn't strictly enforce auth, but the token will be sent in headers
        let users = try await client.getUsers(limit: 5)
        XCTAssertFalse(users.users.isEmpty)

        // 4. Clear token after test
        await ApiClient.setToken(nil)
    }

    func testAuthenticationTokenFlow() async throws {
        // Test full authentication flow: login -> set token -> request -> logout (clear token)

        // 1. Login
        let authResponse = try await client.login(username: "emilys", password: "emilyspass")
        XCTAssertNotNil(authResponse.accessToken)

        // 2. Store token
        await ApiClient.setToken(authResponse.accessToken)

        // 3. Verify token is set
        let storedToken = await ApiClient.getToken()
        XCTAssertEqual(storedToken, authResponse.accessToken)

        // 4. Make authenticated requests
        let posts = try await client.getPosts(limit: 3)
        XCTAssertFalse(posts.posts.isEmpty)

        let products = try await client.getProducts(limit: 3)
        XCTAssertFalse(products.products.isEmpty)

        // 5. Logout (clear token)
        await ApiClient.setToken(nil)
        let clearedToken = await ApiClient.getToken()
        XCTAssertNil(clearedToken)
    }

    // MARK: - Error Handling Tests

    func testInvalidUserId() async throws {
        do {
            _ = try await client.getUser(id: Int.max)
            XCTFail("Expected to throw notFound error")
        } catch APIError.notFound {
            // Expected error
        } catch {
            XCTFail("Expected APIError.notFound, got \(error)")
        }
    }

    func testPaginationBoundaries() async throws {
        // Test pagination at boundaries
        let firstPage = try await client.getUsers(limit: 1, skip: 0)
        XCTAssertEqual(firstPage.users.count, 1)

        // Large skip value
        let largePage = try await client.getUsers(limit: 5, skip: 1000)
        // Should return empty or limited results based on total
        XCTAssertLessThanOrEqual(largePage.users.count, 5)
    }
}
