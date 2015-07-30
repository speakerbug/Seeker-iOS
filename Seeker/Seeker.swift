//
//  Seeker.swift
//  Seeker
//
//  Created by Henry Saniuk on 7/30/15.
//  Copyright (c) 2015 Henry Saniuk. All rights reserved.
//

import Foundation
import SwiftyJSON

class Seeker {
    let id: Int
    let name: String
    let long: Double
    let lat: Double
    let isTagged: Bool
    
    convenience init(json: JSON) {
        let id = json["Id"].intValue
        let name = json["Name"].stringValue
        let long = json["Location"]["Long"].doubleValue
        let lat = json["Location"]["Lat"].doubleValue
        let isTagged = json["isTagged"].boolValue
        self.init(id: id, name: name, long: long, lat: lat, isTagged: isTagged)
    }
    
    init(id: Int, name: String, long: Double, lat: Double, isTagged: Bool) {
        self.id = id
        self.name = name
        self.long = long
        self.lat = lat
        self.isTagged = isTagged
    }
}