//
//  ControlsController.swift
//  teslamote WatchKit Extension
//
//  Created by Tobias Lüscher on 30.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import WatchKit
import Foundation
import TeslaKit


class ControlsController: WKInterfaceController {
    private let teslaAPI = TeslaAPI()
    @IBOutlet weak var lockUnlockLabel: WKInterfaceLabel!
    @IBOutlet weak var valetModeSwitch: WKInterfaceSwitch!
    @IBOutlet weak var speedLimitSwitch: WKInterfaceSwitch!
    @IBOutlet weak var speedLimitLabel: WKInterfaceLabel!
    @IBOutlet weak var speedLimitController: WKInterfaceSlider!
    
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
    
    @IBAction func openTrunk(_ sender: Any) {
        self.teslaAPI.send(.openTrunk, to: SessionManger.vehicle) { (repsonse) in
            if repsonse.result {
                // self.getCarInformation()
            }
        }
    }
    
    @IBAction func lockUnlockCar(_ sender: Any) {
        let command = SessionManger.vehicle.vehicleState.locked ? Command.unlockDoors : Command.lockDoors
        
        teslaAPI.send(command, to: SessionManger.vehicle) { (repsonse) in
            if repsonse.result {
                self.getCarInformation()
            }
        }
    }
    
    @IBAction func flashCar(_ sender: Any) {
        self.teslaAPI.send(.flashLights, to: SessionManger.vehicle) { (repsonse) in
            if repsonse.result {
                // self.getCarInformation()
            }
        }
    }
    
    @IBAction func honkCar(_ sender: Any) {
        self.teslaAPI.send(.honkHorn, to: SessionManger.vehicle) { (repsonse) in
            if repsonse.result {
                // self.getCarInformation()
            }
        }
    }
    
    @IBAction func startCar(_ sender: Any) {
        let parameters = RemoteStart(password: "asdf")
        self.teslaAPI.send(.remoteStart, to: SessionManger.vehicle, parameters: parameters) { (repsonse) in
            if repsonse.result {
                // self.getCarInformation()
            }
        }
    }
    
    @IBAction func valetModeOnOff(_ value: Bool) {
        let parameters = ResetValetPIN(on: value, password: 1234)
        self.teslaAPI.send(.setValetMode, to: SessionManger.vehicle, parameters: parameters) { (repsonse) in
            if repsonse.result {
                self.getCarInformation()
            }
        }
    }
    
    @IBAction func speedLimitOnOff(_ value: Bool) {
        let command = value ? Command.speedLimitActivate : Command.speedLimitDeactivate
        self.teslaAPI.send(command, to: SessionManger.vehicle) { (repsonse) in
            if repsonse.result {
                self.getCarInformation()
            }
        }
    }
    
    @IBAction func setSpeedLimit(_ value: Float) {
        let parameters = SetSpeedLimit(limitMPH: Double(value))
        self.teslaAPI.send(.setSpeedLimit, to: SessionManger.vehicle, parameters: parameters) { (repsonse) in
            if repsonse.result {
                // self.getCarInformation()
                self.speedLimitLabel.setText(String(value))
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
        self.lockUnlockLabel.setText(SessionManger.vehicle.vehicleState.locked ? "Öffnen" : "Schliessen")
        self.valetModeSwitch.setEnabled(SessionManger.vehicle.vehicleState.valetMode)
        self.speedLimitSwitch.setEnabled(SessionManger.vehicle.vehicleState.speedLimitMode.active)
        self.speedLimitController.setEnabled(SessionManger.vehicle.vehicleState.speedLimitMode.active)
        if (SessionManger.vehicle.vehicleState.speedLimitMode.active) {
            self.speedLimitController.setValue(Float(SessionManger.vehicle.vehicleState.speedLimitMode.currentLimitMPH))
            self.speedLimitLabel.setText(String(SessionManger.vehicle.vehicleState.speedLimitMode.currentLimitMPH))
        }
    }
}
