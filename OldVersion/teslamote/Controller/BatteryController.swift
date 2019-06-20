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
import fluid_slider
import UICircularProgressRing

class BatteryController: UIViewController {

    @IBOutlet weak var batteryProgressView: UICircularProgressRing!
    @IBOutlet weak var isChargingLabel: UILabel!
    @IBOutlet weak var remainingFullChargeLabel: UILabel!
    @IBOutlet weak var slider: Slider!
    @IBOutlet weak var chargingPortLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        slider.attributedTextForFraction = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 3
            formatter.maximumFractionDigits = 0
            let string = formatter.string(from: (fraction * 100) as NSNumber) ?? ""
            return NSAttributedString(string: string)
        }
        slider.setMinimumLabelAttributedText(NSAttributedString(string: "0"))
        slider.setMaximumLabelAttributedText(NSAttributedString(string: "100"))
        slider.shadowOffset = CGSize(width: 0, height: 10)
        slider.shadowBlur = 5
        slider.shadowColor = UIColor(white: 0, alpha: 0.1)
        slider.contentViewColor = UIColor(red: 78/255.0, green: 77/255.0, blue: 224/255.0, alpha: 1)
        slider.valueViewColor = .white
        slider.didEndTracking = { slide in
            print(slide.fraction)
            let sliderValueRounded = Float(String(format: "%.1f", slide.fraction))
            self.sliderValueChanged(value: Int(sliderValueRounded! * 100))
        }
        
        displayInformations()
    }
    
    func displayInformations() {
        self.isChargingLabel.text = SessionHandler.shared.vehicle.chargeState.isCharging ? "Charging" : "Not Charging"
        self.remainingFullChargeLabel.text = String(SessionHandler.shared.vehicle.chargeState.timeToFullCharge)
        self.batteryProgressView.value = CGFloat(SessionHandler.shared.vehicle.chargeState.batteryLevel)
        self.chargingPortLabel.text = SessionHandler.shared.vehicle.chargeState.chargePortDoorOpen ? "Close Charge Port" : "Open Charge Port"
        slider.fraction = CGFloat(CGFloat(SessionHandler.shared.vehicle.chargeState.chargeLimitSoc) / 100)

    }
    
    @IBAction func goToMain(_ sender: Any) {
        self.performSegue(withIdentifier: "batteryOverviewToMain", sender: nil)
    }
    
    func sliderValueChanged(value: Int) {
        TeslaComHandler.shared.setChargeLimit(chargeLimit: value).onSuccess { newLimit in
            self.displayInformations()
            print(SessionHandler.shared.vehicle.chargeState.chargeLimitSoc / 100)
            print(CGFloat(SessionHandler.shared.vehicle.chargeState.chargeLimitSoc / 100))
        }
    }
    
    @IBAction func openCloseChargePort(_ sender: Any) {
        TeslaComHandler.shared.openCloseChargePort().onSuccess { isOpen in
            self.displayInformations()
        }
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
