//
//  ViewController.swift
//  teslamote
//
//  Created by Tobias Lüscher on 26.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import UIKit
import TeslaKit

class ViewController: UIViewController {
    
    // let realm = try! Realm()
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    let teslaAPI = TeslaAPI()
    var vehicle = Vehicle()
    @IBOutlet weak var teslaNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NSUbiquitousKeyValueStore.default.synchronize()
        if NSUbiquitousKeyValueStore.default.string(forKey: "token") != nil && NSUbiquitousKeyValueStore.default.string(forKey: "token") != "" {
            let accessToken: AccessToken = AccessToken()
            accessToken.carId = NSUbiquitousKeyValueStore.default.string(forKey: "carId")!
            accessToken.token = NSUbiquitousKeyValueStore.default.string(forKey: "token")!
            setAccessToken(accessToken: accessToken.token)
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
        
        NSUbiquitousKeyValueStore.default.set(loginModel.username, forKey: "username")
        NSUbiquitousKeyValueStore.default.set(loginModel.password, forKey: "password")
        
        teslaAPI.getAccessToken(email: loginModel.username, password: loginModel.password) { (httpResponse, dataOrNil, errorOrNil) in
            guard let accessToken = dataOrNil?.accessToken else { return }
            
            self.setAccessToken(accessToken: accessToken)
            self.performSegue(withIdentifier: "goToMain", sender: nil)
        }
        
    }
    
    @IBAction func loadCarData(_ sender: Any) {
        self.teslaAPI.getData(for: self.vehicle, completion: { (res, data, err) in
            let vehicle = data!
            
            print("Hello, \(vehicle.displayName)")
            self.teslaNameLabel.text = vehicle.displayName
        })
    }
    
    func setAccessToken(accessToken: String) {
        // SessionHandler.shared.teslaAPI.setAccessToken(accessToken)
        self.teslaAPI.setAccessToken(accessToken)
        
        self.teslaAPI.getVehicles { (httpResponse, dataOrNil, errorOrNil) in
            
            guard let vehicle = dataOrNil?.vehicles.first else { return }
            self.vehicle = vehicle
            
            print("Hello, \(vehicle.displayName)")
            let accessTokenModel = AccessToken()
            accessTokenModel.token = accessToken;
            accessTokenModel.carId = "\(vehicle.id)"
            
            print("id: \(vehicle.id)")
            print("vhicleid: \(vehicle.vehicleId)")
            
            // SessionHandler.shared.accessToken = accessTokenModel
            NSUbiquitousKeyValueStore.default.set(accessTokenModel.token, forKey: "token")
            NSUbiquitousKeyValueStore.default.set(accessTokenModel.carId, forKey: "carId")
            NSUbiquitousKeyValueStore.default.synchronize()
            
        }
        
    }
    
}

