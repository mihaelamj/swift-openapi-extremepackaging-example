import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func loginUser(_ input: SharedApiModels.Operations.LoginUser.Input) async throws -> SharedApiModels.Operations.LoginUser.Output {
        let credentials: Components.Schemas.LoginRequest
        switch input.body {
        case .json(let loginRequest):
            credentials = loginRequest
        }

        // Mock authentication - validate credentials
        guard credentials.username == "emilys",
              credentials.password == "emilyspass" else {
            return .badRequest(.init())
        }

        // Return mock auth response
        let authResponse = Components.Schemas.AuthResponse(
            id: 1,
            username: "emilys",
            email: "emily.johnson@x.dummyjson.com",
            firstName: "Emily",
            lastName: "Johnson",
            gender: "female",
            image: "https://dummyjson.com/icon/emilys/128",
            accessToken: "mock-access-token-\(UUID().uuidString)",
            refreshToken: "mock-refresh-token-\(UUID().uuidString)"
        )

        return .ok(.init(body: .json(authResponse)))
    }
}
