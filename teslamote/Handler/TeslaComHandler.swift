//
//  TeslaComHandler.swift
//  teslamote
//
//  Created by Tobias Lüscher on 29.05.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import UIKit
import TeslaKit

class TeslaComHandler: NSObject {
    
    static let shared = TeslaComHandler()
    let teslaAPI = TeslaAPI()
    
    func updateCarInformation() {
        SessionHandler.shared.refreshToken()
        self.teslaAPI.getData(for: SessionHandler.shared.vehicle, completion: { (res, data, err) in
            SessionHandler.shared.vehicle = data!
        })
    }
    
    func flashLights() {
        SessionHandler.shared.refreshToken()
        self.teslaAPI.send(.flashLights, to: SessionHandler.shared.vehicle) { (repsonse) in
            if repsonse.result {
                // self.getCarInformation()
            }
        }
    }
    
    func honkHorn() {
        SessionHandler.shared.refreshToken()
        self.teslaAPI.send(.honkHorn, to: SessionHandler.shared.vehicle) { (repsonse) in
            if repsonse.result {
                // self.getCarInformation()
            }
        }
    }
    
    func turnOnOffClimate() -> Bool {
        SessionHandler.shared.refreshToken()
        let command = SessionHandler.shared.vehicle.climateState.isClimateOn ? Command.stopHVAC : Command.startHVAC
        self.teslaAPI.send(command, to: SessionHandler.shared.vehicle) { (repsonse) in
            if repsonse.result {
                
            }
        }
        return !SessionHandler.shared.vehicle.climateState.isClimateOn
    }
    
    func lockUnlockCar() -> Bool {
        SessionHandler.shared.refreshToken()
        let command = SessionHandler.shared.vehicle.vehicleState.locked ? Command.unlockDoors : Command.lockDoors
        
        teslaAPI.send(command, to: SessionHandler.shared.vehicle) { (repsonse) in
            if repsonse.result {
                self.updateCarInformation()
            }
        }
        return !SessionHandler.shared.vehicle.vehicleState.locked
    }
}
