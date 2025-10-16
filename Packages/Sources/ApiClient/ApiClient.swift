import Foundation
import OpenAPIRuntime
import SharedApiModels
import OpenAPIAsyncHTTPClient
import AsyncHTTPClient
import NIOCore

struct ApiHandler: APIProtocol {
    // All implementations are in separate ApiClient_*.swift files as extensions

    /**

     1. ApiClient_loginUser.swift - User login
     2. ApiClient_getAllUsers.swift - Get all users
     3. ApiClient_getUserById.swift - Get a single user by ID
     4. ApiClient_createUser.swift - Create a new user
     5. ApiClient_getAllPosts.swift - Get all posts
     6. ApiClient_getPostById.swift - Get a single post by ID
     7. ApiClient_createPost.swift - Create a new post
     8. ApiClient_getAllProducts.swift - Get all products
     9. ApiClient_getProductById.swift - Get a single product by ID
     10. ApiClient_createProduct.swift - Create a new product
     11. ApiClient_getAllTodos.swift - Get all todos
     12. ApiClient_getTodoById.swift - Get a single todo by ID
     13. ApiClient_createTodo.swift - Create a new todo
     14. ApiClient_getAllComments.swift - Get all comments
     15. ApiClient_getCommentById.swift - Get a single comment by ID
     16. ApiClient_getAllCarts.swift - Get all carts
     17. ApiClient_getCartById.swift - Get a single cart by ID
     */
}
