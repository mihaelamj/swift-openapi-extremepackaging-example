import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func createUser(_ input: SharedApiModels.Operations.CreateUser.Input) async throws -> SharedApiModels.Operations.CreateUser.Output {
        let newUser: Components.Schemas.User
        switch input.body {
        case .json(let user):
            newUser = user
        }

        // Create response with generated ID
        let createdUser = Components.Schemas.User(
            id: 101, // Mock new user ID
            firstName: newUser.firstName,
            lastName: newUser.lastName,
            maidenName: newUser.maidenName,
            age: newUser.age,
            gender: newUser.gender,
            email: newUser.email,
            phone: newUser.phone,
            username: newUser.username,
            birthDate: newUser.birthDate,
            image: newUser.image,
            address: newUser.address
        )

        return .created(.init(body: .json(createdUser)))
    }
}
