import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getUserById(_ input: SharedApiModels.Operations.GetUserById.Input) async throws -> SharedApiModels.Operations.GetUserById.Output {
        let userId = input.path.id

        // Return 404 for user IDs > 100
        guard userId <= 100 else {
            return .notFound(.init())
        }

        // Mock user data
        let user = Components.Schemas.User(
            id: userId,
            firstName: "User\(userId)",
            lastName: "Test",
            maidenName: "Smith",
            age: 25,
            gender: userId % 2 == 0 ? "male" : "female",
            email: "user\(userId)@example.com",
            phone: "+1234567890",
            username: "user\(userId)",
            birthDate: "1998-05-15",
            image: "https://dummyjson.com/icon/user\(userId)/128",
            address: .init(
                address: "\(userId) Main St",
                city: "Springfield",
                state: "IL",
                postalCode: "62701"
            )
        )

        return .ok(.init(body: .json(user)))
    }
}
