import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getProductById(_ input: SharedApiModels.Operations.GetProductById.Input) async throws -> SharedApiModels.Operations.GetProductById.Output {
        let productId = input.path.id

        // Mock product data
        let product = Components.Schemas.Product(
            id: productId,
            title: "Product \(productId)",
            description: "This is a comprehensive description for product \(productId). It has excellent features and quality.",
            category: "Electronics",
            price: Float(productId * 100 + 99),
            discountPercentage: 12.5,
            rating: 4.7,
            stock: 75,
            brand: "PremiumBrand",
            thumbnail: "https://dummyjson.com/image/product/\(productId)/thumbnail.jpg",
            images: [
                "https://dummyjson.com/image/product/\(productId)/1.jpg",
                "https://dummyjson.com/image/product/\(productId)/2.jpg",
                "https://dummyjson.com/image/product/\(productId)/3.jpg"
            ]
        )

        return .ok(.init(body: .json(product)))
    }
}
