import Foundation
import OpenAPIRuntime
import SharedApiModels

extension ApiHandler {
    func getAllComments(_ input: SharedApiModels.Operations.GetAllComments.Input) async throws -> SharedApiModels.Operations.GetAllComments.Output {
        let output = try await client.openAPIClient.getAllComments(input)
        return output
    }
}
