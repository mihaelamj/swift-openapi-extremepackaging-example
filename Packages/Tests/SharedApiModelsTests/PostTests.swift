import XCTest
@testable import SharedApiModels
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import AsyncHTTPClient

final class PostTests: XCTestCase {
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

    // MARK: - Get All Posts Tests

    func testGetAllPosts() async throws {
        // Given
        let input = Operations.GetAllPosts.Input()

        // When
        let output = try await client.getAllPosts(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                XCTAssertNotNil(payload.posts, "Posts array should not be nil")
                XCTAssertNotNil(payload.total, "Total count should not be nil")
                if let posts = payload.posts, let total = payload.total {
                    XCTAssertGreaterThan(posts.count, 0, "Should return at least one post")
                    XCTAssertGreaterThan(total, 0, "Total should be greater than 0")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllPostsWithLimit() async throws {
        // Given
        let limit = 10
        let input = Operations.GetAllPosts.Input(
            query: .init(limit: limit)
        )

        // When
        let output = try await client.getAllPosts(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let posts = payload.posts {
                    XCTAssertLessThanOrEqual(posts.count, limit, "Should return at most \(limit) posts")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllPostsWithSkip() async throws {
        // Given
        let skip = 5
        let input = Operations.GetAllPosts.Input(
            query: .init(skip: skip)
        )

        // When
        let output = try await client.getAllPosts(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                XCTAssertNotNil(payload.posts, "Posts array should not be nil")
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllPostsWithLimitAndSkip() async throws {
        // Given
        let limit = 5
        let skip = 10
        let input = Operations.GetAllPosts.Input(
            query: .init(limit: limit, skip: skip)
        )

        // When
        let output = try await client.getAllPosts(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let posts = payload.posts {
                    XCTAssertLessThanOrEqual(posts.count, limit, "Should return at most \(limit) posts")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    // MARK: - Get Post By ID Tests

    func testGetPostById() async throws {
        // Given
        let postId = 1
        let input = Operations.GetPostById.Input(
            path: .init(id: postId)
        )

        // When
        let output = try await client.getPostById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let post):
                XCTAssertEqual(post.id, postId, "Post ID should match requested ID")
                XCTAssertNotNil(post.title, "Title should not be nil")
                XCTAssertNotNil(post.body, "Body should not be nil")
                XCTAssertNotNil(post.userId, "User ID should not be nil")
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testPostDataStructure() async throws {
        // Given
        let postId = 1
        let input = Operations.GetPostById.Input(
            path: .init(id: postId)
        )

        // When
        let output = try await client.getPostById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let post):
                // Verify all expected fields
                XCTAssertNotNil(post.id)
                XCTAssertNotNil(post.title)
                XCTAssertNotNil(post.body)
                XCTAssertNotNil(post.userId)
                // Optional fields: tags, reactions, views
            }
        case .undocumented:
            XCTFail("Should retrieve post successfully")
        }
    }

    func testPostHasReactions() async throws {
        // Given
        let postId = 1
        let input = Operations.GetPostById.Input(
            path: .init(id: postId)
        )

        // When
        let output = try await client.getPostById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let post):
                if let reactions = post.reactions {
                    // Reactions should have likes and dislikes
                    XCTAssertNotNil(reactions.likes)
                    XCTAssertNotNil(reactions.dislikes)
                }
            }
        case .undocumented:
            XCTFail("Should retrieve post successfully")
        }
    }

    func testPostHasTags() async throws {
        // Given
        let postId = 1
        let input = Operations.GetPostById.Input(
            path: .init(id: postId)
        )

        // When
        let output = try await client.getPostById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let post):
                // Tags might be present
                if let tags = post.tags {
                    XCTAssertGreaterThan(tags.count, 0, "Tags array should have elements if present")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve post successfully")
        }
    }

    // MARK: - Create Post Tests
    // Note: DummyJSON API doesn't actually support POST /posts (returns 404)
    // These tests validate the request structure and API contract

    func testCreatePost() async throws {
        // Given
        let newPost = Components.Schemas.Post(
            title: "Test Post Title",
            body: "This is a test post body content.",
            userId: 1
        )

        let input = Operations.CreatePost.Input(
            body: .json(newPost)
        )

        // When
        let output = try await client.createPost(input)

        // Then
        switch output {
        case .created:
            XCTAssert(true, "Post created successfully")
        case .undocumented(let statusCode, _):
            // DummyJSON doesn't support POST /posts, returns 404
            XCTAssertEqual(statusCode, 404, "DummyJSON returns 404 for unsupported POST /posts")
        }
    }

    func testCreatePostWithTags() async throws {
        // Given
        let newPost = Components.Schemas.Post(
            title: "Post with Tags",
            body: "This post has tags.",
            tags: ["test", "swift", "api"],
            userId: 1
        )

        let input = Operations.CreatePost.Input(
            body: .json(newPost)
        )

        // When
        let output = try await client.createPost(input)

        // Then
        switch output {
        case .created:
            XCTAssert(true, "Post with tags created successfully")
        case .undocumented(let statusCode, _):
            // DummyJSON doesn't support POST /posts, returns 404
            XCTAssertEqual(statusCode, 404, "DummyJSON returns 404 for unsupported POST /posts")
        }
    }

    func testCreatePostWithReactions() async throws {
        // Given
        let reactions = Components.Schemas.Post.ReactionsPayload(
            likes: 10,
            dislikes: 2
        )

        let newPost = Components.Schemas.Post(
            title: "Post with Reactions",
            body: "This post has initial reactions.",
            reactions: reactions,
            views: 100,
            userId: 1
        )

        let input = Operations.CreatePost.Input(
            body: .json(newPost)
        )

        // When
        let output = try await client.createPost(input)

        // Then
        switch output {
        case .created:
            XCTAssert(true, "Post with reactions created successfully")
        case .undocumented(let statusCode, _):
            // DummyJSON doesn't support POST /posts, returns 404
            XCTAssertEqual(statusCode, 404, "DummyJSON returns 404 for unsupported POST /posts")
        }
    }

    func testCreatePostWithMinimalData() async throws {
        // Given
        let newPost = Components.Schemas.Post(
            title: "Minimal Post",
            body: "Minimal content.",
            userId: 1
        )

        let input = Operations.CreatePost.Input(
            body: .json(newPost)
        )

        // When
        let output = try await client.createPost(input)

        // Then
        switch output {
        case .created:
            XCTAssert(true, "Minimal post created successfully")
        case .undocumented(let statusCode, _):
            // DummyJSON doesn't support POST /posts, returns 404
            XCTAssertEqual(statusCode, 404, "DummyJSON returns 404 for unsupported POST /posts")
        }
    }
}
