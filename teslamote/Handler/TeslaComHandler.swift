//
//  TeslaComHandler.swift
//  teslamote
//
//  Created by Tobias Lüscher on 29.05.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import UIKit
import TeslaKit
import EasyFutures

class TeslaComHandler: NSObject {
    
    static let shared = TeslaComHandler()
    let teslaAPI = TeslaAPI()
    
    func updateCarInformation(vehicle: Vehicle) -> Future<Vehicle> {
        self.teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        let promise = Promise<Vehicle>()
        SessionHandler.shared.refreshToken()
        SessionHandler.shared.wakeVehicle(vehicle: vehicle).onSuccess { isOnline in
            self.teslaAPI.getData(vehicle.id, completion: { (res, data, err) in
                SessionHandler.shared.vehicle = data!
                promise.success(data!)
            })
        }
        return promise.future
    }
    
    func flashLights() {
        self.teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        SessionHandler.shared.refreshToken()
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            self.teslaAPI.send(.flashLights, to: SessionHandler.shared.vehicle) { (repsonse) in
                if repsonse.result {
                    // self.getCarInformation()
                }
            }
        }
    }
    
    func honkHorn() {
        self.teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        SessionHandler.shared.refreshToken()
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            self.teslaAPI.send(.honkHorn, to: SessionHandler.shared.vehicle) { (repsonse) in
                if repsonse.result {
                    // self.getCarInformation()
                }
            }
        }
    }
    
    func turnOnOffClimate() -> Future<Bool> {
        self.teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        SessionHandler.shared.refreshToken()
        let promise = Promise<Bool>()
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            let command = SessionHandler.shared.vehicle.climateState.isClimateOn ? Command.stopHVAC : Command.startHVAC
            self.teslaAPI.send(command, to: SessionHandler.shared.vehicle) { (repsonse) in
                if repsonse.result {
                    self.updateCarInformation(vehicle: SessionHandler.shared.vehicle).onSuccess { vehicle in
                        SessionHandler.shared.vehicle.climateState.isClimateOn = command == Command.startHVAC
                        promise.success(SessionHandler.shared.vehicle.climateState.isClimateOn)
                    }
                }
            }
        }
        return promise.future
    }
    
    func lockUnlockCar() -> Future<Bool> {
        self.teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        let promise = Promise<Bool>()
        SessionHandler.shared.refreshToken()
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            let command = SessionHandler.shared.vehicle.vehicleState.locked ? Command.unlockDoors : Command.lockDoors
            self.teslaAPI.send(command, to: SessionHandler.shared.vehicle) { (repsonse) in
                if repsonse.result {
                    self.updateCarInformation(vehicle: SessionHandler.shared.vehicle).onSuccess { vehicle in
                        SessionHandler.shared.vehicle.vehicleState.locked = command == Command.lockDoors
                        promise.success(SessionHandler.shared.vehicle.vehicleState.locked)
                    }
                }
            }
        }
        return promise.future
    }
    
    func setChargeLimit(chargeLimit: Int) -> Future<Int> {
        self.teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        let promise = Promise<Int>()
        let parameters = SetChargeLimit(limitValue: Double(chargeLimit))
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            self.teslaAPI.send(.setChargeLimit, to: SessionHandler.shared.vehicle, parameters: parameters) { (repsonse) in
                if repsonse.result {
                    self.updateCarInformation(vehicle: SessionHandler.shared.vehicle).onSuccess { vehicle in
                        SessionHandler.shared.vehicle.chargeState.chargeLimitSoc = chargeLimit
                        promise.success(SessionHandler.shared.vehicle.chargeState.chargeLimitSoc)
                    }
                }
            }
        }
        return promise.future
    }
    
    func openCloseChargePort() -> Future<Bool> {
        self.teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        let promise = Promise<Bool>()
        SessionHandler.shared.refreshToken()
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            let command = SessionHandler.shared.vehicle.chargeState.chargePortDoorOpen ? Command.closeChargePort : Command.openChargePort
            self.teslaAPI.send(command, to: SessionHandler.shared.vehicle) { (repsonse) in
                if repsonse.result {
                    self.updateCarInformation(vehicle: SessionHandler.shared.vehicle).onSuccess { vehicle in
                        SessionHandler.shared.vehicle.chargeState.chargePortDoorOpen = command == Command.openChargePort
                        promise.success(SessionHandler.shared.vehicle.chargeState.chargePortDoorOpen)
                    }
                }
            }
        }
        return promise.future
    }
}
