import Foundation
import OpenAPIRuntime
import SharedApiModels
import OpenAPIAsyncHTTPClient
import AsyncHTTPClient
import NIOCore

extension ApiHandler {
    func getUserById(_ input: SharedApiModels.Operations.GetUserById.Input) async throws -> SharedApiModels.Operations.GetUserById.Output {
        // Create an HTTP client-backed OpenAPI client targeting the configured server
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        // Use syncShutdown() in defer because `await` is not allowed in a defer block.
        defer { Task { try? await httpClient.shutdown() } }
        let client = Client(
            serverURL: try Servers.Server1.url(),
            transport: AsyncHTTPClientTransport(configuration: .init(client: httpClient))
        )

        // Forward the call to the generated client and return its output
        let output = try await client.getUserById(input)
        return output
    }
}
