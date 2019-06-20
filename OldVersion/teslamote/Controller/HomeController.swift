//
//  HomeController.swift
//  teslamote
//
//  Created by Tobias Lüscher on 15.05.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import UIKit
import Lottie

class HomeController: UIViewController {
    
    @IBOutlet weak var batteryTitle: UILabel!
    @IBOutlet weak var temperaturTitleLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var batteryMileLable: UILabel!
    @IBOutlet weak var batteryMileSubTitleLabel: UILabel!
    @IBOutlet weak var batteryChargeLabel: UILabel!
    @IBOutlet weak var batteryChargeSubTitleLabel: UILabel!
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var batteryView: UIView!
    @IBOutlet weak var animatedBatteryView: AnimationView!
    @IBOutlet weak var teslaNameLabel: UILabel!
    
    // var updateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateDisplayInformations), userInfo: nil, repeats: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayInformations();
        // Do any additional setup after loading the view.
        setFontDynamic(label: temperatureLabel)
        setFontDynamic(label: batteryMileLable)
        setFontDynamic(label: batteryChargeLabel)
        setFontDynamic(label: batteryTitle)
        setFontDynamic(label: temperaturTitleLabel)
        setFontDynamic(label: batteryMileSubTitleLabel)
        setFontDynamic(label: batteryChargeSubTitleLabel)
        setFontDynamic(label: teslaNameLabel)
        setRoundedCorners(uiview: temperatureView)
        setRoundedCorners(uiview: batteryView)
        animatedBatteryView.animation = Animation.named("battery")
        animatedBatteryView.currentProgress = AnimationProgressTime((SessionHandler.shared.vehicle.chargeState.batteryLevel/100))
    }
    
    func setFontDynamic(label: UILabel) {
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
    }
    
    func setRoundedCorners(uiview: UIView) {
        uiview.layer.cornerRadius = 20.0
        uiview.clipsToBounds = true
    }
    
    func updateDisplayInformations() {
        TeslaComHandler.shared.updateCarInformation(vehicle: SessionHandler.shared.vehicle).onSuccess { vehicle in
            self.displayInformations()
        }
    }
    
    func displayInformations() {
        let distanceMiles = Measurement(value: SessionHandler.shared.vehicle.chargeState.batteryRange, unit: UnitLength.miles)
        self.teslaNameLabel.text = SessionHandler.shared.vehicle.displayName
        self.temperatureLabel.text = "\(String(describing: SessionHandler.shared.vehicle.climateState.insideTemperature!))°"
        self.batteryChargeLabel.text = "\(SessionHandler.shared.vehicle.chargeState.batteryLevel)%"
        self.batteryMileLable.text = "\(String(Int((distanceMiles.converted(to: UnitLength.kilometers).value).rounded()))) Km"
    }
    
    func dispatchAll() {
        // self.updateTimer.invalidate()
    }
    
    @IBAction func triggerFlashLight(_ sender: Any) {
        TeslaComHandler.shared.flashLights()
    }
    
    @IBAction func triggerFans(_ sender: Any) {
        TeslaComHandler.shared.turnOnOffClimate().onSuccess { isClimateOn in
            let message = isClimateOn ? "Klima ist nun an" : "Klima ist nun aus"
            let alert = UIAlertController(title: "Klima Status", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func lockUnlock(_ sender: Any) {
        TeslaComHandler.shared.lockUnlockCar().onSuccess { isLocked in
            let message = isLocked ? "Türen sind nun geschlossen" : "Türen sind nun offen"
            let alert = UIAlertController(title: "Tür Status", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func honkHorn(_ sender: Any) {
        TeslaComHandler.shared.honkHorn()
    }
    
    @IBAction func goToBattery(_ sender: Any) {
        self.dispatchAll()
        self.performSegue(withIdentifier: "goToBatteryMain", sender: nil)
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
