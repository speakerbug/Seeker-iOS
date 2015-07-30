//
//  AuthenticationManager.swift
//  Seeker
//
//  Created by Henry Saniuk on 7/29/15.
//  Copyright (c) 2015 Henry Saniuk. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class AuthenticationManager: NSObject {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    private struct Constants {
        static let sharedManager = AuthenticationManager()
    }
    
    class var sharedManager: AuthenticationManager {
        return Constants.sharedManager
    }
    
    var userID: Int {
        get {
            return defaults.integerForKey("userID")
        } set(newID) {
            defaults.setInteger(newID, forKey: "userID")
        }
    }
    
    func logoutUser() {
        self.userID = 0
    }
    
    var userIsLoggedIn: Bool {
        return self.userID != 0
    }
    
}