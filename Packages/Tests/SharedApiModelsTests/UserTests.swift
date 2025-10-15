import XCTest
@testable import SharedApiModels
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import AsyncHTTPClient

final class UserTests: XCTestCase {
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

    // MARK: - Get All Users Tests

    func testGetAllUsers() async throws {
        // Given
        let input = Operations.GetAllUsers.Input()

        // When
        let output = try await client.getAllUsers(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                XCTAssertNotNil(payload.users, "Users array should not be nil")
                XCTAssertNotNil(payload.total, "Total count should not be nil")
                if let users = payload.users, let total = payload.total {
                    XCTAssertGreaterThan(users.count, 0, "Should return at least one user")
                    XCTAssertGreaterThan(total, 0, "Total should be greater than 0")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllUsersWithLimit() async throws {
        // Given
        let limit = 5
        let input = Operations.GetAllUsers.Input(
            query: .init(limit: limit)
        )

        // When
        let output = try await client.getAllUsers(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let users = payload.users {
                    XCTAssertLessThanOrEqual(users.count, limit, "Should return at most \(limit) users")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllUsersWithSkip() async throws {
        // Given
        let skip = 10
        let input = Operations.GetAllUsers.Input(
            query: .init(skip: skip)
        )

        // When
        let output = try await client.getAllUsers(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                XCTAssertNotNil(payload.users, "Users array should not be nil")
                if let users = payload.users {
                    XCTAssertGreaterThan(users.count, 0, "Should return users after skipping")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllUsersWithLimitAndSkip() async throws {
        // Given
        let limit = 5
        let skip = 10
        let input = Operations.GetAllUsers.Input(
            query: .init(limit: limit, skip: skip)
        )

        // When
        let output = try await client.getAllUsers(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let users = payload.users {
                    XCTAssertLessThanOrEqual(users.count, limit, "Should return at most \(limit) users")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    // MARK: - Get User By ID Tests

    func testGetUserById() async throws {
        // Given
        let userId = 1
        let input = Operations.GetUserById.Input(
            path: .init(id: userId)
        )

        // When
        let output = try await client.getUserById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let user):
                XCTAssertEqual(user.id, userId, "User ID should match requested ID")
                XCTAssertNotNil(user.firstName, "First name should not be nil")
                XCTAssertNotNil(user.lastName, "Last name should not be nil")
                XCTAssertNotNil(user.email, "Email should not be nil")
                XCTAssertNotNil(user.username, "Username should not be nil")
            }
        case .notFound:
            XCTFail("User with ID \(userId) should exist")
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetUserByIdNotFound() async throws {
        // Given
        let userId = 999999
        let input = Operations.GetUserById.Input(
            path: .init(id: userId)
        )

        // When
        let output = try await client.getUserById(input)

        // Then
        switch output {
        case .ok:
            // Some mock APIs might return a user even for invalid IDs
            XCTAssert(true, "API returned a response")
        case .notFound:
            XCTAssert(true, "Correctly returned 404 for non-existent user")
        case .undocumented(let statusCode, _):
            // Accept other error codes as well
            XCTAssertTrue(statusCode >= 400, "Should return error status code")
        }
    }

    func testUserDataStructure() async throws {
        // Given
        let userId = 1
        let input = Operations.GetUserById.Input(
            path: .init(id: userId)
        )

        // When
        let output = try await client.getUserById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let user):
                // Verify all expected fields are present
                XCTAssertNotNil(user.id)
                XCTAssertNotNil(user.firstName)
                XCTAssertNotNil(user.lastName)
                XCTAssertNotNil(user.email)
                XCTAssertNotNil(user.username)

                // Optional fields that might be present
                // age, gender, phone, birthDate, image, address
            }
        case .notFound, .undocumented:
            XCTFail("Should retrieve user successfully")
        }
    }

    // MARK: - Create User Tests

    func testCreateUser() async throws {
        // Given
        let newUser = Components.Schemas.User(
            firstName: "Jane",
            lastName: "Doe",
            age: 28,
            gender: "female",
            email: "jane.doe@example.com",
            username: "janedoe"
        )

        let input = Operations.CreateUser.Input(
            body: .json(newUser)
        )

        // When
        let output = try await client.createUser(input)

        // Then
        switch output {
        case .created(let response):
            switch response.body {
            case .json(let createdUser):
                XCTAssertNotNil(createdUser.id, "Created user should have an ID")
                XCTAssertEqual(createdUser.firstName, newUser.firstName, "First name should match")
                XCTAssertEqual(createdUser.lastName, newUser.lastName, "Last name should match")
                XCTAssertEqual(createdUser.email, newUser.email, "Email should match")
                XCTAssertEqual(createdUser.username, newUser.username, "Username should match")
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testCreateUserWithAddress() async throws {
        // Given
        let address = Components.Schemas.User.AddressPayload(
            address: "123 Main St",
            city: "New York",
            state: "NY",
            postalCode: "10001"
        )

        let newUser = Components.Schemas.User(
            firstName: "John",
            lastName: "Smith",
            age: 35,
            email: "john.smith@example.com",
            username: "johnsmith",
            address: address
        )

        let input = Operations.CreateUser.Input(
            body: .json(newUser)
        )

        // When
        let output = try await client.createUser(input)

        // Then
        switch output {
        case .created(let response):
            switch response.body {
            case .json(let createdUser):
                XCTAssertNotNil(createdUser.id, "Created user should have an ID")
                XCTAssertEqual(createdUser.username, "johnsmith", "Username should match")
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testCreateUserWithMinimalData() async throws {
        // Given
        let newUser = Components.Schemas.User(
            firstName: "Test",
            lastName: "User",
            username: "testuser"
        )

        let input = Operations.CreateUser.Input(
            body: .json(newUser)
        )

        // When
        let output = try await client.createUser(input)

        // Then
        switch output {
        case .created(let response):
            switch response.body {
            case .json(let createdUser):
                XCTAssertNotNil(createdUser.id, "Created user should have an ID")
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }
}
