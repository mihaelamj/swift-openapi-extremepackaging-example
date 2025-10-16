import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getCartById(_ input: SharedApiModels.Operations.GetCartById.Input) async throws -> SharedApiModels.Operations.GetCartById.Output {
        let cartId = input.path.id

        // Mock cart products
        let products: [Components.Schemas.Cart.ProductsPayloadPayload] = (1...4).map { productIndex in
            let productId = productIndex + cartId * 10
            let price = Double(productIndex * 150 + 50)
            let quantity = productIndex
            let itemTotal = Double((productIndex * 150 + 50) * productIndex)
            let discountedItemTotal = itemTotal * 0.875

            return Components.Schemas.Cart.ProductsPayloadPayload(
                id: productId,
                title: "Product \(productId)",
                price: price,
                quantity: quantity,
                total: itemTotal,
                discountPercentage: 12.5,
                discountedTotal: discountedItemTotal
            )
        }

        let total = products.reduce(0.0) { $0 + ($1.total ?? 0.0) }
        let discountedTotal = products.reduce(0.0) { $0 + ($1.discountedTotal ?? 0.0) }
        let totalQuantity = products.reduce(0) { $0 + ($1.quantity ?? 0) }

        // Mock cart data
        let cart = Components.Schemas.Cart(
            id: cartId,
            products: products,
            total: total,
            discountedTotal: discountedTotal,
            userId: (cartId % 10) + 1,
            totalProducts: products.count,
            totalQuantity: totalQuantity
        )

        return .ok(.init(body: .json(cart)))
    }
}
