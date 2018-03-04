import Foundation

print("Hello!")

//http://games.espn.com/flb/leaguerosters?leagueId=172095
let leagueID = "172095"
let seasonID = "2017"
let leagueRostersURLString = "http://games.espn.com/flb/leaguerosters?leagueId=\(leagueID)&seasonId=\(seasonID)"
let leagueRostersURL = URL(string: leagueRostersURLString)!


let session = URLSession.shared
let request = URLRequest(url: leagueRostersURL)

var sema = DispatchSemaphore( value: 0 )

func needsAuthentication(response :URLResponse) -> Bool {
    return response.url?.absoluteString.range(of: "signin") != nil
}

let task = session.dataTask(with: request) { (data, response, error) in
    print("Reponse Received")
    if let error = error {
        print("Error: \(String(describing: error))")
    }
    
    if let response = response {
        
        if needsAuthentication(response: response) {
            print("Needs Authentication")
        } else {
            print("Response: \(String(describing: response))")
        }
    }
    
    if let data = data {
        print("Data: \(String(describing: data))")
    }
    
    sema.signal()
}

task.resume()

print("Waiting...")
sema.wait()

print("Complete")
