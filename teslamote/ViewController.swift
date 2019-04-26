//
//  ViewController.swift
//  teslamote
//
//  Created by Tobias Lüscher on 26.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import UIKit
import TeslaKit
import RealmSwift

class ViewController: UIViewController {
    
    // let realm = try! Realm()
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    let teslaAPI = TeslaAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func login(_ sender: Any) {
        let loginModel = Login()
        loginModel.username = usernameInput.text!
        loginModel.password = usernameInput.text!
        
        // Get the default Realm
        let realm = try! Realm()
        
        // Persist your data easily
        try! realm.write {
            realm.add(loginModel)
        }
        
        teslaAPI.getAccessToken(email: loginModel.username, password: loginModel.password) { (httpResponse, dataOrNil, errorOrNil) in
            guard let accessToken = dataOrNil?.accessToken else { return }
            
            if (accessToken != "") {
                let accessTokenModel = AccessToken()
                accessTokenModel.token = accessToken;
                SessionHandler.shared.teslaAPI.setAccessToken(accessToken)
                try! realm.write {
                    realm.add(accessTokenModel)
                }
            }
        }
        
    }
    
}

