//
//  ChargingController.swift
//  teslamote WatchKit Extension
//
//  Created by Tobias Lüscher on 30.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import WatchKit
import Foundation
import TeslaKit


class ChargingController: WKInterfaceController {
    private let teslaAPI = TeslaAPI()
    @IBOutlet weak var batteryDistanceLabel: WKInterfaceLabel!
    @IBOutlet weak var batteryChargingLimitLabel: WKInterfaceLabel!
    @IBOutlet weak var chargePortOpenCloseLabel: WKInterfaceLabel!
    @IBOutlet weak var progressBarDistance: WKInterfaceImage!
    @IBOutlet weak var batterChargeLimitSlider: WKInterfaceSlider!
    
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

    @IBAction func openChargingPort(_ sender: Any) {
        let command = SessionManger.vehicle.chargeState.chargePortDoorOpen ? Command.closeChargePort : Command.openChargePort
        self.teslaAPI.send(command, to: SessionManger.vehicle) { (repsonse) in
            if repsonse.result {
                self.getCarInformation()
            }
        }
    }
    @IBAction func setChargeLimit(_ value: Float) {
        let parameters = SetChargeLimit(limitValue: Double(value))
        self.teslaAPI.send(.setChargeLimit, to: SessionManger.vehicle, parameters: parameters) { (repsonse) in
            if repsonse.result {
                SessionManger.vehicle.chargeState.chargeLimitSoc = Int(value)
                self.setCarInformation()
                // self.getCarInformation()
            }
        }
    }
    
    func getCarInformation() {
        self.teslaAPI.getData(for: SessionManger.vehicle, completion: { (res, data, err) in
            SessionManger.vehicle = data!
            self.setCarInformation()
        })
        
    }
    
    func setCarInformation() {
        self.batteryDistanceLabel.setText(String((SessionManger.vehicle.chargeState.estBatteryRange * 1.609344).rounded()))
        self.batteryChargingLimitLabel.setText("\(String(SessionManger.vehicle.chargeState.chargeLimitSoc))%")
        self.chargePortOpenCloseLabel.setText(SessionManger.vehicle.chargeState.chargePortDoorOpen ? "Close charge Port" : "Open charge Port")
        self.batterChargeLimitSlider.setValue(Float(SessionManger.vehicle.chargeState.chargeLimitSoc))
        self.progressBarDistance.setRelativeWidth((CGFloat(SessionManger.vehicle.chargeState.batteryLevel / 100)), withAdjustment: 0)
    }
}
