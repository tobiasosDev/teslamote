//
//  BatteryControllerViewController.swift
//  teslamote
//
//  Created by Tobias Lüscher on 02.06.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import UIKit
import Lottie
import TeslaKit

class BatteryController: UIViewController {

    @IBOutlet weak var batteryProgressView: AnimationView!
    @IBOutlet weak var isChargingLabel: UILabel!
    @IBOutlet weak var remainingFullChargeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        batteryProgressView.animation = Animation.named("chargePercent")
        batteryProgressView.currentProgress = AnimationProgressTime((SessionHandler.shared.vehicle.chargeState.batteryLevel/100))
        displayInformations()
    }
    
    func displayInformations() {
        self.isChargingLabel.text = SessionHandler.shared.vehicle.chargeState.isCharging ? "Charging" : "Not Charging"
        self.remainingFullChargeLabel.text = String(SessionHandler.shared.vehicle.chargeState.timeToFullCharge)
    }
    
    @IBAction func goToMain(_ sender: Any) {
        self.performSegue(withIdentifier: "batteryOverviewToMain", sender: nil)
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
