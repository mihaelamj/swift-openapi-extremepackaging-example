// The Swift Programming Language
// https://docs.swift.org/swift-book

import Vapor
import OpenAPIRuntime
import OpenAPIVapor
import SharedApiModels

// Function to print curl commands for each endpoint
func printCurlCommands() {
    let baseUrl = "http://localhost:8080"
    
    print("\n=== API ENDPOINTS CURL COMMANDS ===\n")
    
//    // Mock Get Current User
//    print("1. Get Current User:")
//    print("   curl -X GET \(baseUrl)/mocks/user/me -H \"Accept: application/json\"\n")
//    
//    // Mock Get User Image
//    print("2. Get User Image:")
//    print("   curl -X GET \(baseUrl)/mocks/user/images/img-123 -H \"Accept: image/jpeg\" --output image.jpg\n")
//    
//    // Mock Set Preferred Name
//    print("3. Set Preferred Name:")
//    print("   curl -X POST \(baseUrl)/mocks/user/preferred-name \\")
//    print("        -H \"Content-Type: application/json\" \\")
//    print("        -H \"Accept: application/json\" \\")
//    print("        -d '{\"text\":\"Call me John\"}'\n")
//    
//    // Mock Set Biometrics
//    print("4. Set Biometrics:")
//    print("   curl -X POST \(baseUrl)/mocks/user/biometrics \\")
//    print("        -H \"Content-Type: application/json\" \\")
//    print("        -H \"Accept: application/json\" \\")
//    print("        -d \"{\\\"text\\\":\\\"I'm 82kg, 183cm, born 15 June 1992\\\"}\"\n")
//    
//    // Mock Get Plan Status Summary
//    print("5. Get Plan Status Summary:")
//    print("   curl -X GET \"\(baseUrl)/mocks/plans/status?date=2025-05-04&timezone=America/Los_Angeles\" \\")
//    print("        -H \"Accept: application/json\"\n")
//    
//    // Mock Read Track Workout
//    print("6. Read Track Workout:")
//    print("   curl -X GET \(baseUrl)/mocks/track/workout/workout-123 \\")
//    print("        -H \"Accept: application/json\"\n")
//    
//    // Mock Read Track Meal
//    print("7. Read Track Meal:")
//    print("   curl -X GET \(baseUrl)/mocks/track/meal/meal-123 \\")
//    print("        -H \"Accept: application/json\"\n")
//    
//    // Mock Read Many Messages
//    print("8. Read Many Messages:")
//    print("   curl -X GET \(baseUrl)/mocks/messages \\")
//    print("        -H \"Accept: application/json\"\n")
//    
//    // Mock Chat Agent Responses Sync
//    print("9. Chat Agent Responses Sync:")
//    print("   curl -X POST \(baseUrl)/mocks/messages/agent-responses-sync \\")
//    print("        -H \"Content-Type: application/json\" \\")
//    print("        -H \"Accept: application/json\" \\")
//    print("        -d '{\"content\":\"Tell me about my nutrition plan\"}'\n")
//    
//    // Mock Chat Agent Responses
//    print("10. Chat Agent Responses:")
//    print("    curl -X POST \(baseUrl)/mocks/messages/agent-responses \\")
//    print("         -H \"Content-Type: application/json\" \\")
//    print("         -H \"Accept: text/event-stream\" \\")
//    print("         -d '{\"content\":\"What workouts should I do today?\"}'\n")
//    
//    // Mock Chat Agent Responses Multipart
//    print("11. Chat Agent Responses Multipart:")
//    print("    curl -X POST \(baseUrl)/mocks/messages/agent-responses-multipart \\")
//    print("         -H \"Accept: text/event-stream\" \\")
//    print("         -F \"content=How many calories in this meal?\" \\")
//    print("         -F \"images=@/path/to/meal-image.jpg\"\n")
    
    print("=== END OF API ENDPOINTS ===\n")
}


// Create Vapor application.
let app = try await Application.make()

// Create a VaporTransport using that application.
let transport = VaporTransport(routesBuilder: app)

// Create an instance of handler type that conforms the generated protocol
// defininig the service API.
let handler = ApiHandler()
//
//
//// Call the generated function on the implementation to add its request
//// handlers to the app.
try handler.registerHandlers(on: transport, serverURL: Servers.Server1.url())
//
//
//
// Print curl commands for each endpoint
printCurlCommands()
//
//
//// Start the app as you would normally.
try await app.execute()
