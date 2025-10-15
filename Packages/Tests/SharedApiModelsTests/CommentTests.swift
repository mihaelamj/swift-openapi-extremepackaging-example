import XCTest
@testable import SharedApiModels
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import AsyncHTTPClient

final class CommentTests: XCTestCase {
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

    // MARK: - Get All Comments Tests

    func testGetAllComments() async throws {
        // Given
        let input = Operations.GetAllComments.Input()

        // When
        let output = try await client.getAllComments(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                XCTAssertNotNil(payload.comments, "Comments array should not be nil")
                XCTAssertNotNil(payload.total, "Total count should not be nil")
                if let comments = payload.comments, let total = payload.total {
                    XCTAssertGreaterThan(comments.count, 0, "Should return at least one comment")
                    XCTAssertGreaterThan(total, 0, "Total should be greater than 0")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllCommentsWithLimit() async throws {
        // Given
        let limit = 10
        let input = Operations.GetAllComments.Input(
            query: .init(limit: limit)
        )

        // When
        let output = try await client.getAllComments(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let comments = payload.comments {
                    XCTAssertLessThanOrEqual(comments.count, limit, "Should return at most \(limit) comments")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllCommentsDefaultLimit() async throws {
        // Given - using default limit of 30
        let input = Operations.GetAllComments.Input()

        // When
        let output = try await client.getAllComments(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let comments = payload.comments {
                    XCTAssertLessThanOrEqual(comments.count, 30, "Should use default limit of 30")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    // MARK: - Get Comment By ID Tests

    func testGetCommentById() async throws {
        // Given
        let commentId = 1
        let input = Operations.GetCommentById.Input(
            path: .init(id: commentId)
        )

        // When
        let output = try await client.getCommentById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let comment):
                XCTAssertEqual(comment.id, commentId, "Comment ID should match requested ID")
                XCTAssertNotNil(comment.body, "Comment body should not be nil")
                XCTAssertNotNil(comment.postId, "Post ID should not be nil")
                XCTAssertNotNil(comment.user, "User should not be nil")
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testCommentDataStructure() async throws {
        // Given
        let commentId = 1
        let input = Operations.GetCommentById.Input(
            path: .init(id: commentId)
        )

        // When
        let output = try await client.getCommentById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let comment):
                // Verify all expected fields
                XCTAssertNotNil(comment.id)
                XCTAssertNotNil(comment.body)
                XCTAssertNotNil(comment.postId)
                XCTAssertNotNil(comment.likes)
                XCTAssertNotNil(comment.user)

                // Verify data types
                if let id = comment.id {
                    XCTAssertGreaterThan(id, 0, "Comment ID should be positive")
                }

                if let postId = comment.postId {
                    XCTAssertGreaterThan(postId, 0, "Post ID should be positive")
                }

                if let body = comment.body {
                    XCTAssertFalse(body.isEmpty, "Comment body should not be empty")
                }

                if let likes = comment.likes {
                    XCTAssertGreaterThanOrEqual(likes, 0, "Likes should be non-negative")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve comment successfully")
        }
    }

    func testCommentHasUserInformation() async throws {
        // Given
        let commentId = 1
        let input = Operations.GetCommentById.Input(
            path: .init(id: commentId)
        )

        // When
        let output = try await client.getCommentById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let comment):
                if let user = comment.user {
                    XCTAssertNotNil(user.id, "User ID should not be nil")
                    XCTAssertNotNil(user.username, "Username should not be nil")
                    XCTAssertNotNil(user.fullName, "Full name should not be nil")

                    if let userId = user.id {
                        XCTAssertGreaterThan(userId, 0, "User ID should be positive")
                    }

                    if let username = user.username {
                        XCTAssertFalse(username.isEmpty, "Username should not be empty")
                    }

                    if let fullName = user.fullName {
                        XCTAssertFalse(fullName.isEmpty, "Full name should not be empty")
                    }
                }
            }
        case .undocumented:
            XCTFail("Should retrieve comment successfully")
        }
    }

    func testCommentBelongsToPost() async throws {
        // Given
        let commentId = 1
        let input = Operations.GetCommentById.Input(
            path: .init(id: commentId)
        )

        // When
        let output = try await client.getCommentById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let comment):
                if let postId = comment.postId {
                    XCTAssertGreaterThan(postId, 0, "Comment should belong to a valid post")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve comment successfully")
        }
    }

    func testCommentHasLikes() async throws {
        // Given
        let commentId = 1
        let input = Operations.GetCommentById.Input(
            path: .init(id: commentId)
        )

        // When
        let output = try await client.getCommentById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let comment):
                XCTAssertNotNil(comment.likes)
                if let likes = comment.likes {
                    XCTAssertGreaterThanOrEqual(likes, 0, "Likes count should be non-negative")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve comment successfully")
        }
    }

    func testMultipleComments() async throws {
        // Given
        let limit = 5
        let input = Operations.GetAllComments.Input(
            query: .init(limit: limit)
        )

        // When
        let output = try await client.getAllComments(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let comments = payload.comments {
                    XCTAssertGreaterThan(comments.count, 0, "Should return comments")

                    // Verify each comment has required fields
                    for comment in comments {
                        XCTAssertNotNil(comment.id)
                        XCTAssertNotNil(comment.body)
                        XCTAssertNotNil(comment.postId)
                        XCTAssertNotNil(comment.user)
                    }

                    // Verify comments have different IDs
                    let ids = comments.compactMap { $0.id }
                    let uniqueIds = Set(ids)
                    XCTAssertEqual(ids.count, uniqueIds.count, "All comment IDs should be unique")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testCommentsFromDifferentPosts() async throws {
        // Given
        let input = Operations.GetAllComments.Input(
            query: .init(limit: 20)
        )

        // When
        let output = try await client.getAllComments(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let comments = payload.comments {
                    let postIds = comments.compactMap { $0.postId }
                    let uniquePostIds = Set(postIds)

                    // Comments should belong to multiple posts
                    XCTAssertGreaterThan(uniquePostIds.count, 1, "Should have comments from multiple posts")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testCommentBodyNotEmpty() async throws {
        // Given
        let input = Operations.GetAllComments.Input(
            query: .init(limit: 10)
        )

        // When
        let output = try await client.getAllComments(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let comments = payload.comments {
                    // All comments should have non-empty bodies
                    for comment in comments {
                        if let body = comment.body {
                            XCTAssertFalse(body.isEmpty, "Comment body should not be empty")
                            XCTAssertGreaterThan(body.count, 0, "Comment should have content")
                        }
                    }
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testCommentUserConsistency() async throws {
        // Given
        let commentId = 1
        let input = Operations.GetCommentById.Input(
            path: .init(id: commentId)
        )

        // When
        let output = try await client.getCommentById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let comment):
                if let user = comment.user {
                    // If username exists, it should match the user ID pattern
                    if let username = user.username, let userId = user.id {
                        XCTAssertFalse(username.isEmpty)
                        XCTAssertGreaterThan(userId, 0)
                    }

                    // Full name and username should be consistent
                    if let fullName = user.fullName, let username = user.username {
                        XCTAssertFalse(fullName.isEmpty)
                        XCTAssertFalse(username.isEmpty)
                    }
                }
            }
        case .undocumented:
            XCTFail("Should retrieve comment successfully")
        }
    }
}
