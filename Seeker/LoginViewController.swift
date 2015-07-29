//
//  LoginViewController.swift
//  Seeker
//
//  Created by Henry Saniuk on 7/29/15.
//  Copyright (c) 2015 Henry Saniuk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
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
    
    
    @IBAction func createUserButtonClicked(sender: UIButton) {
        let name = usernameField.text
        if ( name == "" ) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Error"
            alertView.message = "Please enter a name"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else {
            
            Alamofire.request(.POST, "http://seeker.henrysaniuk.com:9002/api/user/new?name=\(name)", parameters: ["create":true]).responseJSON { (_, _, data, _) in
                let json = JSON(data!)
                    println(json)
                    AuthenticationManager.sharedManager.userID = json.intValue;
                    self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}


