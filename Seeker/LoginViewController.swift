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
    var clicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func createUserButtonClicked(sender: UIButton) {
        let name = usernameField.text.stringByReplacingOccurrencesOfString(" ", withString: "")
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
    
    func keyboardWillShow(sender: NSNotification) {
        
        if !clicked {
            self.view.frame.origin.y -= 100
            clicked = true
        }
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        
        if clicked {
            self.view.frame.origin.y += 100
            clicked = false
        }
        
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}


