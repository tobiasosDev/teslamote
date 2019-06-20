//
//  TeslaComHandler.swift
//  teslamote
//
//  Created by Tobias Lüscher on 29.05.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import UIKit
import TeslaSwift
import EasyFutures

enum TeslaComHandler {
    // static let shared = TeslaComHandler()
    
    static func updateCarInformation(vehicle: Vehicle) -> Future<VehicleExtended> {
        let promise = Promise<VehicleExtended>()
        SessionHandler.shared.wakeVehicle(vehicle: vehicle).onSuccess { isOnline in
            SessionHandler.teslaAPI.getAllData(vehicle).done { vehicleNew in
                SessionHandler.shared.vehicle = vehicleNew
                promise.success(vehicleNew)
                }.catch { error in
                    print(error)
            }
        }
        return promise.future
    }
    
    static func flashLights() {
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            SessionHandler.teslaAPI.sendCommandToVehicle(SessionHandler.shared.vehicle, command: .flashLights).done { (repsonse) in
                print("lights flashed")
            }
        }
    }
    
    static func honkHorn() {
        let teslaAPI = TeslaAPI()
        teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        SessionHandler.shared.refreshToken()
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            teslaAPI.send(.honkHorn, to: SessionHandler.shared.vehicle) { (repsonse) in
                if repsonse.result {
                    // self.getCarInformation()
                }
            }
        }
    }
    
    static func turnOnOffClimate() -> Future<Bool> {
        let teslaAPI = TeslaAPI()
        teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        SessionHandler.shared.refreshToken()
        let promise = Promise<Bool>()
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            let command = SessionHandler.shared.vehicle.climateState.isClimateOn ? Command.stopHVAC : Command.startHVAC
            teslaAPI.send(command, to: SessionHandler.shared.vehicle) { (repsonse) in
                if repsonse.result {
                    TeslaComHandler.updateCarInformation(vehicle: SessionHandler.shared.vehicle).onSuccess { vehicle in
                        SessionHandler.shared.vehicle.climateState.isClimateOn = command == Command.startHVAC
                        promise.success(SessionHandler.shared.vehicle.climateState.isClimateOn)
                    }
                }
            }
        }
        return promise.future
    }
    
    static func lockUnlockCar() -> Future<Bool> {
        let teslaAPI = TeslaAPI()
        teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        let promise = Promise<Bool>()
        SessionHandler.shared.refreshToken()
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            let command = SessionHandler.shared.vehicle.vehicleState.locked ? Command.unlockDoors : Command.lockDoors
            teslaAPI.send(command, to: SessionHandler.shared.vehicle) { (repsonse) in
                if repsonse.result {
                    TeslaComHandler.updateCarInformation(vehicle: SessionHandler.shared.vehicle).onSuccess { vehicle in
                        SessionHandler.shared.vehicle.vehicleState.locked = command == Command.lockDoors
                        promise.success(SessionHandler.shared.vehicle.vehicleState.locked)
                    }
                }
            }
        }
        return promise.future
    }
    
    static func setChargeLimit(chargeLimit: Int) -> Future<Int> {
        let teslaAPI = TeslaAPI()
        teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        let promise = Promise<Int>()
        let parameters = SetChargeLimit(limitValue: Double(chargeLimit))
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            teslaAPI.send(.setChargeLimit, to: SessionHandler.shared.vehicle, parameters: parameters) { (repsonse) in
                if repsonse.result {
                    TeslaComHandler.updateCarInformation(vehicle: SessionHandler.shared.vehicle).onSuccess { vehicle in
                        SessionHandler.shared.vehicle.chargeState.chargeLimitSoc = chargeLimit
                        promise.success(SessionHandler.shared.vehicle.chargeState.chargeLimitSoc)
                    }
                }
            }
        }
        return promise.future
    }
    
    static func openCloseChargePort() -> Future<Bool> {
        let teslaAPI = TeslaAPI()
        teslaAPI.setAccessToken(SessionHandler.shared.accessTokenLocal.accessToken!)
        let promise = Promise<Bool>()
        SessionHandler.shared.refreshToken()
        SessionHandler.shared.wakeVehicle(vehicle: SessionHandler.shared.vehicle).onSuccess { isOnline in
            let command = SessionHandler.shared.vehicle.chargeState.chargePortDoorOpen ? Command.closeChargePort : Command.openChargePort
            teslaAPI.send(command, to: SessionHandler.shared.vehicle) { (repsonse) in
                if repsonse.result {
                    TeslaComHandler.updateCarInformation(vehicle: SessionHandler.shared.vehicle).onSuccess { vehicle in
                        SessionHandler.shared.vehicle.chargeState.chargePortDoorOpen = command == Command.openChargePort
                        promise.success(SessionHandler.shared.vehicle.chargeState.chargePortDoorOpen)
                    }
                }
            }
        }
        return promise.future
    }
}
