//
//  ViewController.swift
//  teslamote
//
//  Created by Tobias Lüscher on 26.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // let realm = try! Realm()
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if  SessionHandler.shared.hasLoginCredentials() {
            SessionHandler.shared.loginWithSavedCredentials()
        } else {
            let alert = UIAlertController(title: "Keine Login Daten", message: "Bitte loggen Sie sich ein", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func login(_ sender: Any) {
        let loginModel = Login()
        loginModel.username = usernameInput.text!
        loginModel.password = passwordInput.text!
        
        SessionHandler.shared.login(username: loginModel.username, password: loginModel.password)
        
    }
    
}

