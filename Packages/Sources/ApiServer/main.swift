// The Swift Programming Language
// https://docs.swift.org/swift-book

import Vapor
import OpenAPIRuntime
import OpenAPIVapor
import SharedApiModels
import OpenAPILoggingMiddleware

// Function to print curl commands for each endpoint
func printCurlCommands() {
    let baseUrl = "http://localhost:8080"

    print("\n🚀 ApiServer is running at \(baseUrl)")
    print("\n=== API ENDPOINTS CURL COMMANDS ===\n")

    // Authentication
    print("1. Login User:")
    print("   curl -X POST \(baseUrl)/auth/login \\")
    print("        -H \"Content-Type: application/json\" \\")
    print("        -H \"Accept: application/json\" \\")
    print("        -d '{\"username\":\"emilys\",\"password\":\"emilyspass\"}'\n")

    // Users
    print("2. Get All Users:")
    print("   curl -X GET \"\(baseUrl)/users?limit=10&skip=0\" \\")
    print("        -H \"Accept: application/json\"\n")

    print("3. Get User By ID:")
    print("   curl -X GET \(baseUrl)/users/1 \\")
    print("        -H \"Accept: application/json\"\n")

    print("4. Create User:")
    print("   curl -X POST \(baseUrl)/users \\")
    print("        -H \"Content-Type: application/json\" \\")
    print("        -H \"Accept: application/json\" \\")
    print("        -d '{\"firstName\":\"John\",\"lastName\":\"Doe\",\"email\":\"john@example.com\"}'\n")

    // Posts
    print("5. Get All Posts:")
    print("   curl -X GET \"\(baseUrl)/posts?limit=10&skip=0\" \\")
    print("        -H \"Accept: application/json\"\n")

    print("6. Get Post By ID:")
    print("   curl -X GET \(baseUrl)/posts/1 \\")
    print("        -H \"Accept: application/json\"\n")

    print("7. Create Post:")
    print("   curl -X POST \(baseUrl)/posts \\")
    print("        -H \"Content-Type: application/json\" \\")
    print("        -H \"Accept: application/json\" \\")
    print("        -d '{\"title\":\"My Post\",\"body\":\"Post content\",\"userId\":1}'\n")

    // Products
    print("8. Get All Products:")
    print("   curl -X GET \"\(baseUrl)/products?limit=10&skip=0\" \\")
    print("        -H \"Accept: application/json\"\n")

    print("9. Get Product By ID:")
    print("   curl -X GET \(baseUrl)/products/1 \\")
    print("        -H \"Accept: application/json\"\n")

    print("10. Create Product:")
    print("    curl -X POST \(baseUrl)/products \\")
    print("         -H \"Content-Type: application/json\" \\")
    print("         -H \"Accept: application/json\" \\")
    print("         -d '{\"title\":\"New Product\",\"price\":99.99}'\n")

    // Todos
    print("11. Get All Todos:")
    print("    curl -X GET \"\(baseUrl)/todos?limit=10\" \\")
    print("         -H \"Accept: application/json\"\n")

    print("12. Get Todo By ID:")
    print("    curl -X GET \(baseUrl)/todos/1 \\")
    print("         -H \"Accept: application/json\"\n")

    print("13. Create Todo:")
    print("    curl -X POST \(baseUrl)/todos \\")
    print("         -H \"Content-Type: application/json\" \\")
    print("         -H \"Accept: application/json\" \\")
    print("         -d '{\"todo\":\"Buy groceries\",\"completed\":false,\"userId\":1}'\n")

    // Comments
    print("14. Get All Comments:")
    print("    curl -X GET \"\(baseUrl)/comments?limit=10\" \\")
    print("         -H \"Accept: application/json\"\n")

    print("15. Get Comment By ID:")
    print("    curl -X GET \(baseUrl)/comments/1 \\")
    print("         -H \"Accept: application/json\"\n")

    // Carts
    print("16. Get All Carts:")
    print("    curl -X GET \"\(baseUrl)/carts?limit=10\" \\")
    print("         -H \"Accept: application/json\"\n")

    print("17. Get Cart By ID:")
    print("    curl -X GET \(baseUrl)/carts/1 \\")
    print("         -H \"Accept: application/json\"\n")

    print("=== END OF API ENDPOINTS ===\n")
}


// Create Vapor application.
let app = try await Application.make()

// Create logging middleware
let loggingMiddleware = LoggingMiddleware(appName: "DummyJSON", logPrefix: "🖥️ ApiServer: ")

// Create a VaporTransport using that application.
let transport = VaporTransport(routesBuilder: app)

// Create an instance of handler type that conforms the generated protocol
// defininig the service API.
let handler = ApiHandler()
//
//
//// Call the generated function on the implementation to add its request
//// handlers to the app.
try handler.registerHandlers(on: transport, serverURL: Servers.Server1.url(), middlewares: [loggingMiddleware])
//
//
//
// Print curl commands for each endpoint
printCurlCommands()
//
//
//// Start the app as you would normally.
try await app.execute()
