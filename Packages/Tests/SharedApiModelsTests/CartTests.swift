import XCTest
@testable import SharedApiModels
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import AsyncHTTPClient

final class CartTests: XCTestCase {
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

    // MARK: - Get All Carts Tests

    func testGetAllCarts() async throws {
        // Given
        let input = Operations.GetAllCarts.Input()

        // When
        let output = try await client.getAllCarts(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                XCTAssertNotNil(payload.carts, "Carts array should not be nil")
                XCTAssertNotNil(payload.total, "Total count should not be nil")
                if let carts = payload.carts, let total = payload.total {
                    XCTAssertGreaterThan(carts.count, 0, "Should return at least one cart")
                    XCTAssertGreaterThan(total, 0, "Total should be greater than 0")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllCartsWithLimit() async throws {
        // Given
        let limit = 5
        let input = Operations.GetAllCarts.Input(
            query: .init(limit: limit)
        )

        // When
        let output = try await client.getAllCarts(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let carts = payload.carts {
                    XCTAssertLessThanOrEqual(carts.count, limit, "Should return at most \(limit) carts")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllCartsDefaultLimit() async throws {
        // Given - using default limit of 30
        let input = Operations.GetAllCarts.Input()

        // When
        let output = try await client.getAllCarts(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let carts = payload.carts {
                    XCTAssertLessThanOrEqual(carts.count, 30, "Should use default limit of 30")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    // MARK: - Get Cart By ID Tests

    func testGetCartById() async throws {
        // Given
        let cartId = 1
        let input = Operations.GetCartById.Input(
            path: .init(id: cartId)
        )

        // When
        let output = try await client.getCartById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let cart):
                XCTAssertEqual(cart.id, cartId, "Cart ID should match requested ID")
                XCTAssertNotNil(cart.userId, "User ID should not be nil")
                XCTAssertNotNil(cart.products, "Products array should not be nil")
                XCTAssertNotNil(cart.total, "Total should not be nil")
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testCartDataStructure() async throws {
        // Given
        let cartId = 1
        let input = Operations.GetCartById.Input(
            path: .init(id: cartId)
        )

        // When
        let output = try await client.getCartById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let cart):
                // Verify all expected fields
                XCTAssertNotNil(cart.id)
                XCTAssertNotNil(cart.userId)
                XCTAssertNotNil(cart.products)
                XCTAssertNotNil(cart.total)
                XCTAssertNotNil(cart.discountedTotal)
                XCTAssertNotNil(cart.totalProducts)
                XCTAssertNotNil(cart.totalQuantity)
            }
        case .undocumented:
            XCTFail("Should retrieve cart successfully")
        }
    }

    func testCartHasProducts() async throws {
        // Given
        let cartId = 1
        let input = Operations.GetCartById.Input(
            path: .init(id: cartId)
        )

        // When
        let output = try await client.getCartById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let cart):
                if let products = cart.products {
                    XCTAssertGreaterThan(products.count, 0, "Cart should have at least one product")

                    // Verify product structure
                    for product in products {
                        XCTAssertNotNil(product.id, "Product ID should not be nil")
                        XCTAssertNotNil(product.title, "Product title should not be nil")
                        XCTAssertNotNil(product.price, "Product price should not be nil")
                        XCTAssertNotNil(product.quantity, "Product quantity should not be nil")
                        XCTAssertNotNil(product.total, "Product total should not be nil")
                    }
                }
            }
        case .undocumented:
            XCTFail("Should retrieve cart successfully")
        }
    }

    func testCartProductHasDiscount() async throws {
        // Given
        let cartId = 1
        let input = Operations.GetCartById.Input(
            path: .init(id: cartId)
        )

        // When
        let output = try await client.getCartById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let cart):
                if let products = cart.products {
                    for product in products {
                        // Products in cart may have discount information
                        if let discount = product.discountPercentage {
                            XCTAssertGreaterThanOrEqual(discount, 0, "Discount should be non-negative")
                        }

                        if let discountedTotal = product.discountedTotal {
                            XCTAssertGreaterThanOrEqual(discountedTotal, 0, "Discounted total should be non-negative")
                        }
                    }
                }
            }
        case .undocumented:
            XCTFail("Should retrieve cart successfully")
        }
    }

    func testCartTotalsAreCorrect() async throws {
        // Given
        let cartId = 1
        let input = Operations.GetCartById.Input(
            path: .init(id: cartId)
        )

        // When
        let output = try await client.getCartById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let cart):
                if let total = cart.total {
                    XCTAssertGreaterThan(total, 0, "Cart total should be positive")
                }

                if let discountedTotal = cart.discountedTotal {
                    XCTAssertGreaterThan(discountedTotal, 0, "Discounted total should be positive")

                    // Discounted total should be less than or equal to total
                    if let total = cart.total {
                        XCTAssertLessThanOrEqual(discountedTotal, total, "Discounted total should not exceed total")
                    }
                }

                if let totalProducts = cart.totalProducts {
                    XCTAssertGreaterThan(totalProducts, 0, "Total products count should be positive")
                }

                if let totalQuantity = cart.totalQuantity {
                    XCTAssertGreaterThan(totalQuantity, 0, "Total quantity should be positive")

                    // Total quantity should be >= total products (since quantities can be > 1)
                    if let totalProducts = cart.totalProducts {
                        XCTAssertGreaterThanOrEqual(totalQuantity, totalProducts, "Total quantity should be >= products count")
                    }
                }
            }
        case .undocumented:
            XCTFail("Should retrieve cart successfully")
        }
    }

    func testCartBelongsToUser() async throws {
        // Given
        let cartId = 1
        let input = Operations.GetCartById.Input(
            path: .init(id: cartId)
        )

        // When
        let output = try await client.getCartById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let cart):
                if let userId = cart.userId {
                    XCTAssertGreaterThan(userId, 0, "User ID should be positive")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve cart successfully")
        }
    }

    func testMultipleCartsReturnDifferentData() async throws {
        // Given
        let cart1Input = Operations.GetCartById.Input(path: .init(id: 1))
        let cart2Input = Operations.GetCartById.Input(path: .init(id: 2))

        // When
        let cart1Output = try await client.getCartById(cart1Input)
        let cart2Output = try await client.getCartById(cart2Input)

        // Then
        switch (cart1Output, cart2Output) {
        case (.ok(let response1), .ok(let response2)):
            switch (response1.body, response2.body) {
            case (.json(let cart1), .json(let cart2)):
                // Carts should have different IDs
                XCTAssertNotEqual(cart1.id, cart2.id, "Different cart IDs should return different carts")

                // They may belong to different users
                if let user1 = cart1.userId, let user2 = cart2.userId {
                    // Just verify both have valid user IDs
                    XCTAssertGreaterThan(user1, 0)
                    XCTAssertGreaterThan(user2, 0)
                }
            }
        default:
            XCTFail("Should retrieve both carts successfully")
        }
    }
}
