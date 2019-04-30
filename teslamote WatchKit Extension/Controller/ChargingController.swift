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
                // self.getCarInformation()
                self.batteryChargingLimitLabel.setText(String(value))
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
        batteryDistanceLabel.setText(String((SessionManger.vehicle.chargeState.estBatteryRange * 1.609344).rounded()))
        batteryChargingLimitLabel.setText(String(SessionManger.vehicle.chargeState.chargeLimitSoc))
        chargePortOpenCloseLabel.setText(SessionManger.vehicle.chargeState.chargePortDoorOpen ? "Close charge Port" : "Open charge Port")
    }
}
