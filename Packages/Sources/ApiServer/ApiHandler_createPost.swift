import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func createPost(_ input: SharedApiModels.Operations.CreatePost.Input) async throws -> SharedApiModels.Operations.CreatePost.Output {
        // Extract post from request body
        switch input.body {
        case .json:
            // Post created successfully
            return .created(.init())
        }
    }
}
