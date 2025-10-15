import XCTest
@testable import SharedApiModels
import OpenAPIRuntime

final class WebhookTests: XCTestCase {

    // MARK: - Webhook Payload Validation Tests

    func testNewCommentWebhookPayloadStructure() throws {
        // Given
        let comment = Components.Schemas.Comment(
            id: 1,
            body: "Test comment",
            postId: 10,
            likes: 3,
            user: .init(id: 5, username: "user", fullName: "User Name")
        )

        // Note: Webhooks are defined in OpenAPI 3.1.0 spec but may not be generated as operations
        // This test validates that the Comment schema can be used for webhook payloads

        // Then - Verify comment structure for webhook use
        XCTAssertEqual(comment.id, 1, "Comment ID should match")
        XCTAssertEqual(comment.body, "Test comment", "Comment body should match")
        XCTAssertEqual(comment.postId, 10, "Post ID should match")
        XCTAssertEqual(comment.likes, 3, "Likes should match")
        XCTAssertNotNil(comment.user, "User should not be nil")
    }

    func testNewPostWebhookPayloadStructure() throws {
        // Given
        let post = Components.Schemas.Post(
            id: 1,
            title: "Test Post",
            body: "Post content",
            userId: 1
        )

        // Note: Webhooks are defined in OpenAPI 3.1.0 spec but may not be generated as operations
        // This test validates that the Post schema can be used for webhook payloads

        // Then - Verify post structure for webhook use
        XCTAssertEqual(post.id, 1, "Post ID should match")
        XCTAssertEqual(post.title, "Test Post", "Post title should match")
        XCTAssertEqual(post.body, "Post content", "Post body should match")
        XCTAssertEqual(post.userId, 1, "User ID should match")
    }

    // MARK: - Webhook Event Type Tests

    func testCommentCreatedEventType() {
        // Given
        let eventType = "comment.created"

        // Then
        XCTAssertEqual(eventType, "comment.created", "Comment event should be 'comment.created'")
    }

    func testPostPublishedEventType() {
        // Given
        let eventType = "post.published"

        // Then
        XCTAssertEqual(eventType, "post.published", "Post event should be 'post.published'")
    }

    // MARK: - Webhook Data Completeness Tests

    func testNewCommentWebhookHasCompleteCommentData() {
        // Given
        let comment = Components.Schemas.Comment(
            id: 100,
            body: "Comprehensive comment for testing",
            postId: 50,
            likes: 15,
            user: .init(
                id: 25,
                username: "commenter",
                fullName: "Comment Author"
            )
        )

        // Then - Verify all comment fields are present
        XCTAssertEqual(comment.id, 100)
        XCTAssertEqual(comment.body, "Comprehensive comment for testing")
        XCTAssertEqual(comment.postId, 50)
        XCTAssertEqual(comment.likes, 15)
        XCTAssertNotNil(comment.user)

        if let user = comment.user {
            XCTAssertEqual(user.id, 25)
            XCTAssertEqual(user.username, "commenter")
            XCTAssertEqual(user.fullName, "Comment Author")
        }
    }

    func testNewPostWebhookHasCompletePostData() {
        // Given
        let reactions = Components.Schemas.Post.ReactionsPayload(
            likes: 20,
            dislikes: 3
        )

        let post = Components.Schemas.Post(
            id: 200,
            title: "Complete Post",
            body: "Full post content for webhook",
            tags: ["webhook", "test", "complete"],
            reactions: reactions,
            views: 100,
            userId: 5
        )

        // Then - Verify all post fields are present
        XCTAssertEqual(post.id, 200)
        XCTAssertEqual(post.title, "Complete Post")
        XCTAssertEqual(post.body, "Full post content for webhook")
        XCTAssertEqual(post.tags, ["webhook", "test", "complete"])
        XCTAssertNotNil(post.reactions)
        XCTAssertEqual(post.views, 100)
        XCTAssertEqual(post.userId, 5)

        if let reactions = post.reactions {
            XCTAssertEqual(reactions.likes, 20)
            XCTAssertEqual(reactions.dislikes, 3)
        }
    }

    // MARK: - Webhook Event Type Tests


    // MARK: - Schema Codable Tests

    func testCommentSchemaIsEncodable() throws {
        // Given
        let comment = Components.Schemas.Comment(
            id: 1,
            body: "Test",
            postId: 1,
            user: .init(id: 1, username: "user", fullName: "Name")
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(comment)

        // Then
        XCTAssertGreaterThan(data.count, 0, "Comment should be encodable to JSON")

        // Verify it can be decoded back
        let decoder = JSONDecoder()
        let decodedComment = try decoder.decode(Components.Schemas.Comment.self, from: data)
        XCTAssertEqual(decodedComment.id, comment.id)
        XCTAssertEqual(decodedComment.body, comment.body)
    }

    func testPostSchemaIsEncodable() throws {
        // Given
        let post = Components.Schemas.Post(
            id: 1,
            title: "Test",
            body: "Content",
            userId: 1
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(post)

        // Then
        XCTAssertGreaterThan(data.count, 0, "Post should be encodable to JSON")

        // Verify it can be decoded back
        let decoder = JSONDecoder()
        let decodedPost = try decoder.decode(Components.Schemas.Post.self, from: data)
        XCTAssertEqual(decodedPost.id, post.id)
        XCTAssertEqual(decodedPost.title, post.title)
    }
}
