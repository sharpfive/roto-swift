import Vapor
import HTTP

print("Hello, world!")

print("Yo!")

let drop = try Droplet()

let query = "Wat!!"
let spotifyResponse = try drop.client.get("https://api.spotify.com/v1/search?type=artist&q=\(query)")
print(spotifyResponse)

//import Vapor
//
//let drop = try Droplet()
//
//drop.get("hello") { req in
//    return "Hello Vapor"
//}
//
//try drop.run()
