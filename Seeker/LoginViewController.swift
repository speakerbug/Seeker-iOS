//
//  LoginViewController.swift
//  Seeker
//
//  Created by Henry Saniuk on 7/29/15.
//  Copyright (c) 2015 Henry Saniuk. All rights reserved.
//

import UIKit

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
        println("Create Pressed")
    }
}

