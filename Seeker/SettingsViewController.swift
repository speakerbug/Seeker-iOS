//
//  SettingsViewController.swift
//  Seeker
//
//  Created by Henry Saniuk on 7/29/15.
//  Copyright (c) 2015 Henry Saniuk. All rights reserved.
//

import UIKit
import Alamofire

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logoutUser(sender: UIButton) {
        Alamofire.request(.POST, "http://seeker.henrysaniuk.com:9002/api/user/\(AuthenticationManager.sharedManager.userID)/delete", parameters: ["delete":true]).responseJSON { (_, _, data, _) in
            
            AuthenticationManager.sharedManager.logoutUser()
            self.performSegueWithIdentifier("showLogin", sender: self)
            
        }
    }
}


