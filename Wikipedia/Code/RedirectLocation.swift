//~~~**DELETE THIS HEADER**~~~

import Foundation

class RedirectLocation: NSObject {
    let name: String
    let lat: String
    let long: String
    
    init(name: String, lat: String, long: String) {
        self.name = name
        self.lat = lat
        self.long = long
    }
}

