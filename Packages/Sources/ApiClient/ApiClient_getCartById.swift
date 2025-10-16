import Foundation
import OpenAPIRuntime
import SharedApiModels
import OpenAPIAsyncHTTPClient
import AsyncHTTPClient
import NIOCore

extension ApiHandler {
    func getCartById(_ input: SharedApiModels.Operations.GetCartById.Input) async throws -> SharedApiModels.Operations.GetCartById.Output {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        defer { Task { try? await httpClient.shutdown() } }
        let client = Client(
            serverURL: try Servers.Server1.url(),
            transport: AsyncHTTPClientTransport(configuration: .init(client: httpClient))
        )

        let output = try await client.getCartById(input)
        return output
    }
}
