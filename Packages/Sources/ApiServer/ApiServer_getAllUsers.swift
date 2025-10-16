import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllUsers(_ input: SharedApiModels.Operations.GetAllUsers.Input) async throws -> SharedApiModels.Operations.GetAllUsers.Output {
        let limit = input.query.limit ?? 30
        let skip = input.query.skip ?? 0

        // Mock users data
        let mockUsers = (1...5).map { id in
            Components.Schemas.User(
                id: id + skip,
                firstName: "User\(id + skip)",
                lastName: "Test",
                maidenName: "Smith",
                age: 20 + id,
                gender: id % 2 == 0 ? "male" : "female",
                email: "user\(id + skip)@example.com",
                phone: "+1234567890\(id)",
                username: "user\(id + skip)",
                birthDate: "1990-01-0\(id)",
                image: "https://dummyjson.com/icon/user\(id + skip)/128",
                address: .init(
                    address: "\(id + skip) Main St",
                    city: "Springfield",
                    state: "IL",
                    postalCode: "62701"
                )
            )
        }

        let usersToReturn = Array(mockUsers.prefix(min(limit, mockUsers.count)))

        let response = Operations.GetAllUsers.Output.Ok.Body.JsonPayload(
            users: usersToReturn,
            total: 150,
            skip: skip,
            limit: limit
        )

        return .ok(.init(body: .json(response)))
    }
}
