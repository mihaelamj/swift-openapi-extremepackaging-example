import XCTest
@testable import SharedApiModels
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import AsyncHTTPClient

final class AuthTests: XCTestCase {
    var client: Client!
    var httpClient: HTTPClient!

    override func setUp() async throws {
        try await super.setUp()
        httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        let configuration = AsyncHTTPClientTransport.Configuration(client: httpClient)
        let transport = AsyncHTTPClientTransport(configuration: configuration)
        client = Client(
            serverURL: try Servers.Server1.url(),
            transport: transport
        )
    }

    override func tearDown() async throws {
        try await httpClient.shutdown()
        try await super.tearDown()
    }

    // MARK: - Login Tests

    func testLoginWithValidCredentials() async throws {
        // Given
        let loginRequest = Components.Schemas.LoginRequest(
            username: "emilys",
            password: "emilyspass",
            expiresInMins: 60
        )

        let input = Operations.LoginUser.Input(
            body: .json(loginRequest)
        )

        // When
        let output = try await client.loginUser(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let authResponse):
                XCTAssertNotNil(authResponse.id, "User ID should not be nil")
                XCTAssertEqual(authResponse.username, "emilys", "Username should match")
                XCTAssertNotNil(authResponse.accessToken, "Access token should not be nil")
                XCTAssertNotNil(authResponse.refreshToken, "Refresh token should not be nil")
                XCTAssertNotNil(authResponse.email, "Email should not be nil")
                XCTAssertNotNil(authResponse.firstName, "First name should not be nil")
                XCTAssertNotNil(authResponse.lastName, "Last name should not be nil")
            }
        case .badRequest:
            XCTFail("Login should succeed with valid credentials")
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testLoginWithInvalidCredentials() async throws {
        // Given
        let loginRequest = Components.Schemas.LoginRequest(
            username: "invaliduser",
            password: "wrongpassword",
            expiresInMins: 60
        )

        let input = Operations.LoginUser.Input(
            body: .json(loginRequest)
        )

        // When
        let output = try await client.loginUser(input)

        // Then
        switch output {
        case .ok:
            XCTFail("Login should fail with invalid credentials")
        case .badRequest:
            // Expected behavior for invalid credentials
            XCTAssert(true, "Correctly returned bad request for invalid credentials")
        case .undocumented(let statusCode, _):
            // DummyJSON might return other error codes
            XCTAssertTrue(statusCode >= 400, "Should return error status code")
        }
    }

    func testLoginWithCustomExpiration() async throws {
        // Given
        let loginRequest = Components.Schemas.LoginRequest(
            username: "emilys",
            password: "emilyspass",
            expiresInMins: 30
        )

        let input = Operations.LoginUser.Input(
            body: .json(loginRequest)
        )

        // When
        let output = try await client.loginUser(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let authResponse):
                XCTAssertNotNil(authResponse.accessToken, "Access token should be generated")
            }
        case .badRequest:
            XCTFail("Login should succeed with valid credentials")
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testAuthResponseContainsUserDetails() async throws {
        // Given
        let loginRequest = Components.Schemas.LoginRequest(
            username: "emilys",
            password: "emilyspass"
        )

        let input = Operations.LoginUser.Input(
            body: .json(loginRequest)
        )

        // When
        let output = try await client.loginUser(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let authResponse):
                // Verify all user details are present
                XCTAssertNotNil(authResponse.id)
                XCTAssertNotNil(authResponse.username)
                XCTAssertNotNil(authResponse.email)
                XCTAssertNotNil(authResponse.firstName)
                XCTAssertNotNil(authResponse.lastName)
                XCTAssertNotNil(authResponse.gender)
                XCTAssertNotNil(authResponse.image)
                XCTAssertNotNil(authResponse.accessToken)
                XCTAssertNotNil(authResponse.refreshToken)
            }
        case .badRequest, .undocumented:
            XCTFail("Login should succeed")
        }
    }
}
