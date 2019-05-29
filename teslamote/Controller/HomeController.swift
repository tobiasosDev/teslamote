//
//  HomeController.swift
//  teslamote
//
//  Created by Tobias Lüscher on 15.05.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import UIKit

class HomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func displayInformations() {
        
    }
    
    @IBAction func triggerFlashLight(_ sender: Any) {
        TeslaComHandler.shared.flashLights()
    }
    
    @IBAction func triggerFans(_ sender: Any) {
        let message = TeslaComHandler.shared.turnOnOffClimate() ? "Klima ist nun an" : "Klima ist nun aus"
        let alert = UIAlertController(title: "Klima Status", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func lockUnlock(_ sender: Any) {
        let message = TeslaComHandler.shared.lockUnlockCar() ? "Türen sind nun offen" : "Türen sind nun geschlossen"
        let alert = UIAlertController(title: "Tür Status", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func honkHorn(_ sender: Any) {
        TeslaComHandler.shared.honkHorn()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
