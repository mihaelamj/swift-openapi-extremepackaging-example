import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllCarts(_ input: SharedApiModels.Operations.GetAllCarts.Input) async throws -> SharedApiModels.Operations.GetAllCarts.Output {
        let limit = input.query.limit ?? 30

        // Mock carts data
        let mockCarts: [Components.Schemas.Cart] = (1...5).map { id in
            let products: [Components.Schemas.Cart.ProductsPayloadPayload] = (1...3).map { productIndex in
                let price = Double(productIndex * 100)
                let quantity = productIndex
                let itemTotal = Double(productIndex * 100 * productIndex)
                let discountedItemTotal = itemTotal * 0.9

                return Components.Schemas.Cart.ProductsPayloadPayload(
                    id: productIndex,
                    title: "Product \(productIndex)",
                    price: price,
                    quantity: quantity,
                    total: itemTotal,
                    discountPercentage: 10.0,
                    discountedTotal: discountedItemTotal
                )
            }

            let total = products.reduce(0.0) { $0 + ($1.total ?? 0.0) }
            let discountedTotal = total * 0.9

            return Components.Schemas.Cart(
                id: id,
                products: products,
                total: total,
                discountedTotal: discountedTotal,
                userId: (id % 10) + 1,
                totalProducts: 3,
                totalQuantity: 6
            )
        }

        let cartsToReturn = Array(mockCarts.prefix(min(limit, mockCarts.count)))

        let response = Operations.GetAllCarts.Output.Ok.Body.JsonPayload(
            carts: cartsToReturn,
            total: 50
        )

        return .ok(.init(body: .json(response)))
    }
}
