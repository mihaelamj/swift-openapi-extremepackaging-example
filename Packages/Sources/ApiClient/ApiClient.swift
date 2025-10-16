import Foundation
import OpenAPIRuntime
import SharedApiModels
import OpenAPIAsyncHTTPClient
import OpenAPILoggingMiddleware
import BearerTokenAuthMiddleware

// Actor to safely manage shared state
public actor ApiClientState {
    public static let shared = ApiClientState()

    // Authentication settings
    var token: String?
    var loggingIsEnabled: Bool = true
    var publicOperationIDs: [String] = []

    func isPublicOperation(_ operationID: String) -> Bool {
        return publicOperationIDs.contains(operationID)
    }

    // Methods to update state
    func setToken(_ newToken: String?) {
        self.token = newToken
    }

    func setLoggingEnabled(_ enabled: Bool) {
        self.loggingIsEnabled = enabled
    }

    func setPublicOperationIDs(_ ids: [String]) {
        self.publicOperationIDs = ids
    }
}

public actor ApiClient {

    // MARK: Servers -

    public enum ServerEnvironment: Sendable {
        case production
        case local

        func getURL() throws -> URL {
            switch self {
            case .production:
                return try Servers.Server1.url()
            case .local:
                return try Servers.Server2.url()
            }
        }

        public var description: String {
            switch self {
            case .production: return "Production (DummyJSON API)"
            case .local: return "Local Development"
            }
        }

        public var baseURL: URL {
            get throws {
                try getURL()
            }
        }
    }

    // MARK: Middleware Helper -

    enum MiddlewareType: String, CaseIterable {
        case auth
        case logging

        // Index to ensure the order: [logging, auth]
        var index: Int {
            switch self {
            case .auth: return 1
            case .logging: return 0
            }
        }
    }

    public var openAPIClient: Client
    var transport: any ClientTransport

    // MARK: Settings Properties -
    private(set) public var environment: ServerEnvironment

    // Public setters for the shared state
    public static func setToken(_ token: String?) async {
        await ApiClientState.shared.setToken(token)
    }

    public static func setLoggingEnabled(_ enabled: Bool) async {
        await ApiClientState.shared.setLoggingEnabled(enabled)
    }

    public static func setPublicOperationIDs(_ ids: [String]) async {
        await ApiClientState.shared.setPublicOperationIDs(ids)
    }

    // Public getters for the shared state
    public static func getToken() async -> String? {
        return await ApiClientState.shared.token
    }

    public static func isLoggingEnabled() async -> Bool {
        return await ApiClientState.shared.loggingIsEnabled
    }

    public static func getPublicOperationIDs() async -> [String] {
        return await ApiClientState.shared.publicOperationIDs
    }

    // MARK: Middleware Properties -

    private let authMiddleware: BearerTokenAuthenticationMiddleware
    private let loggingMiddleware: LoggingMiddleware

    var middlewares: [any ClientMiddleware] = []

    // MARK: Init Methods -

    // Initialize with a specific environment
    public init(environment: ServerEnvironment, transport: any ClientTransport = AsyncHTTPClientTransport()) async throws {
        self.transport = transport
        self.environment = environment

        // Initialize middlewares
        let token = await ApiClientState.shared.token
        let loggingEnabled = await ApiClientState.shared.loggingIsEnabled

        // Create all middlewares but they may not all be used based on environment
        self.authMiddleware = BearerTokenAuthenticationMiddleware(
            initialToken: token,
            skipAuthorization: { operationID in
                // Synchronous operation - ideally you'd have a local copy of public IDs
                false
            }
        )

        self.loggingMiddleware = LoggingMiddleware(appName: "DummyJSON", logPrefix: "🚚 APIClient: ")

        // Get the URL for the specified environment
        let serverURL = try environment.getURL()

        // Select the appropriate middlewares based on environment, sorted
        self.middlewares = Self.middlewaresFor(
            environment: environment,
            allowingLogging: loggingEnabled,
            authMiddleware: authMiddleware,
            loggingMiddleware: loggingMiddleware
        )

        self.openAPIClient = Client(
            serverURL: serverURL,
            transport: transport,
            middlewares: middlewares
        )
    }

    // Change server environment at runtime
    public func switchEnvironment(to environment: ServerEnvironment) async throws {
        let serverURL = try environment.getURL()
        self.environment = environment

        // Update middleware selection based on new environment
        let loggingEnabled = await ApiClientState.shared.loggingIsEnabled

        self.middlewares = Self.middlewaresFor(
            environment: environment,
            allowingLogging: loggingEnabled,
            authMiddleware: authMiddleware,
            loggingMiddleware: loggingMiddleware
        )

        self.openAPIClient = Client(
            serverURL: serverURL,
            transport: transport,
            middlewares: middlewares
        )
    }

    // MARK: Middleware Selection Logic -

    static func middlewareTypesFor(environment: ServerEnvironment, allowingLogging: Bool) -> [MiddlewareType] {
        var types: [MiddlewareType] = []

        // Add Logging if enabled
        if allowingLogging {
            types.append(.logging)
        }

        switch environment {
        case .production:
            types.append(.auth)
        case .local:
            types.append(.auth)
        }

        // Sort based on the index defined in the MiddlewareType enum
        return types.sorted { $0.index < $1.index }
    }

    static func middlewaresFor(
        environment: ServerEnvironment,
        allowingLogging: Bool,
        authMiddleware: BearerTokenAuthenticationMiddleware,
        loggingMiddleware: LoggingMiddleware
    ) -> [any ClientMiddleware] {
        let types = middlewareTypesFor(environment: environment, allowingLogging: allowingLogging)
        var result: [any ClientMiddleware] = []

        for type in types {
            switch type {
            case .auth:
                result.append(authMiddleware)
            case .logging:
                result.append(loggingMiddleware)
            }
        }
        return result
    }
}

// MARK: - Shared Client Instance Management -

extension ApiClient {
    // Shared instance for convenience
    nonisolated(unsafe) public static var shared: ApiClient?

    // Initialize the shared instance
    public static func initializeShared(environment: ServerEnvironment, transport: any ClientTransport = AsyncHTTPClientTransport()) async throws {
        shared = try await ApiClient(environment: environment, transport: transport)
    }
}

// MARK: - APIProtocol Implementation -

struct ApiHandler: APIProtocol {
    // All implementations are in separate ApiClient_*.swift files as extensions

    let client: ApiClient

    init(client: ApiClient) {
        self.client = client
    }

    /**
     1. ApiClient_loginUser.swift - User login
     2. ApiClient_getAllUsers.swift - Get all users
     3. ApiClient_getUserById.swift - Get a single user by ID
     4. ApiClient_createUser.swift - Create a new user
     5. ApiClient_getAllPosts.swift - Get all posts
     6. ApiClient_getPostById.swift - Get a single post by ID
     7. ApiClient_createPost.swift - Create a new post
     8. ApiClient_getAllProducts.swift - Get all products
     9. ApiClient_getProductById.swift - Get a single product by ID
     10. ApiClient_createProduct.swift - Create a new product
     11. ApiClient_getAllTodos.swift - Get all todos
     12. ApiClient_getTodoById.swift - Get a single todo by ID
     13. ApiClient_createTodo.swift - Create a new todo
     14. ApiClient_getAllComments.swift - Get all comments
     15. ApiClient_getCommentById.swift - Get a single comment by ID
     16. ApiClient_getAllCarts.swift - Get all carts
     17. ApiClient_getCartById.swift - Get a single cart by ID
     */
}

// Custom API errors
public enum APIError: Error {
    case unexpectedResponse
    case validationError
    case notFound
}
