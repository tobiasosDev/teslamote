//
//  ClimateController.swift
//  teslamote WatchKit Extension
//
//  Created by Tobias Lüscher on 01.05.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import WatchKit
import Foundation
import TeslaKit


class ClimateController: WKInterfaceController {
    private let teslaAPI = TeslaAPI()
    @IBOutlet weak var interiorTemperaturLabel: WKInterfaceLabel!
    @IBOutlet weak var climateTemperaturLabel: WKInterfaceLabel!
    @IBOutlet weak var climateControlSlider: WKInterfaceSlider!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        teslaAPI.setAccessToken(SessionManger.token)
        setCarInformation()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func turnClimateOnOff() {
        let command = SessionManger.vehicle.climateState.isClimateOn ? Command.stopHVAC : Command.startHVAC
        self.teslaAPI.send(command, to: SessionManger.vehicle) { (repsonse) in
            if repsonse.result {
                self.setCarInformation()
            }
        }
    }
    
    @IBAction func setTemperatur(_ value: Float) {
        let parameters = SetChargeLimit(limitValue: Double(value))
        self.teslaAPI.send(.setChargeLimit, to: SessionManger.vehicle, parameters: parameters) { (repsonse) in
            if repsonse.result {
                SessionManger.vehicle.chargeState.chargeLimitSoc = Int(value)
                self.setCarInformation()
                // self.getCarInformation()
            }
        }
    }
    
    
    
    
    func setCarInformation() {
        interiorTemperaturLabel.setText("\(String(describing: SessionManger.vehicle.climateState.insideTemperature!))°C")
        climateTemperaturLabel.setText("\(SessionManger.vehicle.climateState.driverTemperatureSetting)°C")
        climateControlSlider.setEnabled(SessionManger.vehicle.climateState.isClimateOn)
    }
}
