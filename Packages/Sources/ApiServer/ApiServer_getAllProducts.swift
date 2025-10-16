import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllProducts(_ input: SharedApiModels.Operations.GetAllProducts.Input) async throws -> SharedApiModels.Operations.GetAllProducts.Output {
        let limit = input.query.limit ?? 30
        let skip = input.query.skip ?? 0

        // Mock products data
        let mockProducts: [Components.Schemas.Product] = (1...5).map { id in
            let productId = id + skip
            let price = Float(id * 100 + 99)
            let discount = Float(id * 5)
            let rating = Float(4.5 + (Double(id) * 0.1))

            return Components.Schemas.Product(
                id: productId,
                title: "Product \(productId)",
                description: "This is a detailed description for product \(productId)",
                category: "Electronics",
                price: price,
                discountPercentage: discount,
                rating: rating,
                stock: 50 + id,
                brand: "Brand\(id)",
                thumbnail: "https://dummyjson.com/image/product/\(productId)/thumbnail.jpg",
                images: [
                    "https://dummyjson.com/image/product/\(productId)/1.jpg",
                    "https://dummyjson.com/image/product/\(productId)/2.jpg"
                ]
            )
        }

        let productsToReturn = Array(mockProducts.prefix(min(limit, mockProducts.count)))

        let response = Operations.GetAllProducts.Output.Ok.Body.JsonPayload(
            products: productsToReturn,
            total: 200
        )

        return .ok(.init(body: .json(response)))
    }
}
