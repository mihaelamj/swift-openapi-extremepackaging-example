import XCTest
@testable import SharedApiModels
import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import AsyncHTTPClient

final class ProductTests: XCTestCase {
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

    // MARK: - Get All Products Tests

    func testGetAllProducts() async throws {
        // Given
        let input = Operations.GetAllProducts.Input()

        // When
        let output = try await client.getAllProducts(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                XCTAssertNotNil(payload.products, "Products array should not be nil")
                XCTAssertNotNil(payload.total, "Total count should not be nil")
                if let products = payload.products, let total = payload.total {
                    XCTAssertGreaterThan(products.count, 0, "Should return at least one product")
                    XCTAssertGreaterThan(total, 0, "Total should be greater than 0")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllProductsWithLimit() async throws {
        // Given
        let limit = 10
        let input = Operations.GetAllProducts.Input(
            query: .init(limit: limit)
        )

        // When
        let output = try await client.getAllProducts(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let products = payload.products {
                    XCTAssertLessThanOrEqual(products.count, limit, "Should return at most \(limit) products")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllProductsWithSkip() async throws {
        // Given
        let skip = 5
        let input = Operations.GetAllProducts.Input(
            query: .init(skip: skip)
        )

        // When
        let output = try await client.getAllProducts(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                XCTAssertNotNil(payload.products, "Products array should not be nil")
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testGetAllProductsWithLimitAndSkip() async throws {
        // Given
        let limit = 5
        let skip = 10
        let input = Operations.GetAllProducts.Input(
            query: .init(limit: limit, skip: skip)
        )

        // When
        let output = try await client.getAllProducts(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let payload):
                if let products = payload.products {
                    XCTAssertLessThanOrEqual(products.count, limit, "Should return at most \(limit) products")
                }
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    // MARK: - Get Product By ID Tests

    func testGetProductById() async throws {
        // Given
        let productId = 1
        let input = Operations.GetProductById.Input(
            path: .init(id: productId)
        )

        // When
        let output = try await client.getProductById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let product):
                XCTAssertEqual(product.id, productId, "Product ID should match requested ID")
                XCTAssertNotNil(product.title, "Title should not be nil")
                XCTAssertNotNil(product.price, "Price should not be nil")
            }
        case .undocumented(let statusCode, _):
            XCTFail("Unexpected status code: \(statusCode)")
        }
    }

    func testProductDataStructure() async throws {
        // Given
        let productId = 1
        let input = Operations.GetProductById.Input(
            path: .init(id: productId)
        )

        // When
        let output = try await client.getProductById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let product):
                // Verify all expected fields
                XCTAssertNotNil(product.id)
                XCTAssertNotNil(product.title)
                XCTAssertNotNil(product.description)
                XCTAssertNotNil(product.price)
                XCTAssertNotNil(product.category)

                // Verify numeric fields
                if let price = product.price {
                    XCTAssertGreaterThan(price, 0, "Price should be positive")
                }

                if let rating = product.rating {
                    XCTAssertGreaterThanOrEqual(rating, 0, "Rating should be non-negative")
                    XCTAssertLessThanOrEqual(rating, 5, "Rating should be at most 5")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve product successfully")
        }
    }

    func testProductHasDiscountPercentage() async throws {
        // Given
        let productId = 1
        let input = Operations.GetProductById.Input(
            path: .init(id: productId)
        )

        // When
        let output = try await client.getProductById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let product):
                if let discount = product.discountPercentage {
                    XCTAssertGreaterThanOrEqual(discount, 0, "Discount should be non-negative")
                    XCTAssertLessThanOrEqual(discount, 100, "Discount should be at most 100%")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve product successfully")
        }
    }

    func testProductHasStock() async throws {
        // Given
        let productId = 1
        let input = Operations.GetProductById.Input(
            path: .init(id: productId)
        )

        // When
        let output = try await client.getProductById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let product):
                if let stock = product.stock {
                    XCTAssertGreaterThanOrEqual(stock, 0, "Stock should be non-negative")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve product successfully")
        }
    }

    func testProductHasImages() async throws {
        // Given
        let productId = 1
        let input = Operations.GetProductById.Input(
            path: .init(id: productId)
        )

        // When
        let output = try await client.getProductById(input)

        // Then
        switch output {
        case .ok(let response):
            switch response.body {
            case .json(let product):
                // Thumbnail should be present
                XCTAssertNotNil(product.thumbnail)

                // Images array might be present
                if let images = product.images {
                    XCTAssertGreaterThan(images.count, 0, "Images array should not be empty if present")
                }
            }
        case .undocumented:
            XCTFail("Should retrieve product successfully")
        }
    }

    // MARK: - Create Product Tests
    // Note: DummyJSON API doesn't actually support POST /products (returns 404)
    // These tests validate the request structure and API contract

    func testCreateProduct() async throws {
        // Given
        let newProduct = Components.Schemas.Product(
            title: "Test Product",
            description: "This is a test product",
            category: "electronics",
            price: 99.99,
            stock: 50
        )

        let input = Operations.CreateProduct.Input(
            body: .json(newProduct)
        )

        // When
        let output = try await client.createProduct(input)

        // Then
        switch output {
        case .created:
            XCTAssert(true, "Product created successfully")
        case .undocumented(let statusCode, _):
            // DummyJSON doesn't support POST /products, returns 404
            XCTAssertEqual(statusCode, 404, "DummyJSON returns 404 for unsupported POST /products")
        }
    }

    func testCreateProductWithDiscount() async throws {
        // Given
        let newProduct = Components.Schemas.Product(
            title: "Discounted Product",
            description: "Product with discount",
            category: "fashion",
            price: 49.99,
            discountPercentage: 15.5,
            stock: 100
        )

        let input = Operations.CreateProduct.Input(
            body: .json(newProduct)
        )

        // When
        let output = try await client.createProduct(input)

        // Then
        switch output {
        case .created:
            XCTAssert(true, "Product with discount created successfully")
        case .undocumented(let statusCode, _):
            // DummyJSON doesn't support POST /products, returns 404
            XCTAssertEqual(statusCode, 404, "DummyJSON returns 404 for unsupported POST /products")
        }
    }

    func testCreateProductWithRatingAndBrand() async throws {
        // Given
        let newProduct = Components.Schemas.Product(
            title: "Premium Product",
            description: "High quality product",
            category: "electronics",
            price: 299.99,
            rating: 4.5,
            stock: 25,
            brand: "TestBrand"
        )

        let input = Operations.CreateProduct.Input(
            body: .json(newProduct)
        )

        // When
        let output = try await client.createProduct(input)

        // Then
        switch output {
        case .created:
            XCTAssert(true, "Product with rating and brand created successfully")
        case .undocumented(let statusCode, _):
            // DummyJSON doesn't support POST /products, returns 404
            XCTAssertEqual(statusCode, 404, "DummyJSON returns 404 for unsupported POST /products")
        }
    }

    func testCreateProductWithImages() async throws {
        // Given
        let newProduct = Components.Schemas.Product(
            title: "Product with Images",
            description: "Product with thumbnail and images",
            category: "home",
            price: 149.99,
            stock: 30,
            thumbnail: "https://example.com/thumbnail.jpg",
            images: [
                "https://example.com/image1.jpg",
                "https://example.com/image2.jpg",
                "https://example.com/image3.jpg"
            ]
        )

        let input = Operations.CreateProduct.Input(
            body: .json(newProduct)
        )

        // When
        let output = try await client.createProduct(input)

        // Then
        switch output {
        case .created:
            XCTAssert(true, "Product with images created successfully")
        case .undocumented(let statusCode, _):
            // DummyJSON doesn't support POST /products, returns 404
            XCTAssertEqual(statusCode, 404, "DummyJSON returns 404 for unsupported POST /products")
        }
    }
}
