//
//  SessionHandler.swift
//  teslamote
//
//  Created by Tobias Lüscher on 26.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//


import Foundation
import WatchConnectivity
import TeslaSwift
import EasyFutures

class SessionHandler : NSObject, WCSessionDelegate {
    
    // 1: Singleton
    static let shared = SessionHandler()
    public var vehicle: VehicleExtended = demoVehicle
    public var vehicles: [Vehicle] = [Vehicle]()
    public var accessTokenLocal: AuthToken? = nil
    static let teslaAPI: TeslaSwift = TeslaSwift()
    
    // 2: Property to manage session
    private var session = WCSession.default
    
    override init() {
        super.init()
        
        // 3: Start and avtivate session if it's supported
        if isSuported() {
            session.delegate = self
            session.activate()
            self.loginWithSavedCredentials().onError { error in
                print(error)
            }
        }
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
    }
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    
    // MARK: - WCSessionDelegate
    
    // 4: Required protocols
    
    // a
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    // b
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
    }
    
    // c
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
        // Reactivate session
        /**
         * This is to re-activate the session on the phone when the user has switched from one
         * paired watch to second paired one. Calling it like this assumes that you have no other
         * threads/part of your code that needs to be given time before the switch occurs.
         */
        self.session.activate()
    }
    
    func login(username: String, password: String) -> Future<Bool>{
        let promise = Promise<Bool>()
        NSUbiquitousKeyValueStore.default.set(username, forKey: "username")
        NSUbiquitousKeyValueStore.default.set(password, forKey: "password")
        SessionHandler.teslaAPI.authenticate(email: username, password: password).done { (result) in
            // let accessToken = result
            // self.accessTokenLocal = accessToken
            promise.success(true)
            
            //self.setAccessToken(accessToken: self.accessTokenLocal.accessToken!).onSuccess { data in
                
            //}
            }.catch { error in
                print(error)
        }
        return promise.future
    }
    
    func loginWithSavedCredentials() -> Future<Bool> {
        if self.hasLoginCredentials() {
            let username = NSUbiquitousKeyValueStore.default.string(forKey: "username")
            let password = NSUbiquitousKeyValueStore.default.string(forKey: "password")
            return self.login(username: username!, password: password!)
        } else {
            let promise = Promise<Bool>()
            promise.success(false)
            return promise.future
        }
    }

    
    func hasLoginCredentials() -> Bool {
        NSUbiquitousKeyValueStore.default.synchronize()
        return (NSUbiquitousKeyValueStore.default.string(forKey: "username") != nil && NSUbiquitousKeyValueStore.default.string(forKey: "username") != "") && (NSUbiquitousKeyValueStore.default.string(forKey: "password") != nil && NSUbiquitousKeyValueStore.default.string(forKey: "password") != "")
    }
    
//    func refreshToken() {
//        if self.accessTokenLocal!.isValid {
//           SessionHandler.teslaAPI.getRefreshToken(self.accessTokenLocal.refreshToken!) { (httpResponse, dataOrNil, errorOrNil) in
//                if httpResponse.statusCode == 200 {
//                    self.accessTokenLocal = dataOrNil!
//                }
//            }
//        }
//    }
    
    func wakeVehicle(vehicle: Vehicle) -> Future<Bool>{
        let promise = Promise<Bool>()
        if (vehicle.state != "online") {
            SessionHandler.teslaAPI.wakeUp(vehicle: vehicle).done { result in
                promise.success(true)
                }.catch { error in
                    print(error)
            }
        } else {
            promise.success(true)
        }
        return promise.future
    }
    
    func setAccessToken(accessToken: String) -> Future<Bool> {
        let promise = Promise<Bool>()
        // SessionHandler.shared.teslaAPI.setAccessToken(accessToken)
//        self.teslaAPI.setAccessToken(accessToken)
        
        SessionHandler.teslaAPI.getVehicles().done { (vehicleList: [Vehicle]) in
            self.vehicles = vehicleList
            SessionHandler.vehicle = self.vehicles.first! as! VehicleExtended
            
            print("Hello, \(String(describing: SessionHandler.vehicle.displayName))")
            print("id: \(String(describing: SessionHandler.vehicle.id))")
            print("vhicleid: \(String(describing: SessionHandler.vehicle.vehicleID))")
            self.wakeVehicle(vehicle: SessionHandler.vehicle).onSuccess { isOnline in
                TeslaComHandler.updateCarInformation(vehicle: SessionHandler.vehicle).onSuccess { vehicle in
                    promise.success(true)
                }
            }
            }.catch { error in
                print(error)
        }
        return promise.future
    }
    
    /// Observer to receive messages from watch and we be able to response it
    ///
    /// - Parameters:
    ///   - session: session
    ///   - message: message received
    ///   - replyHandler: response handler
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if self.accessTokenLocal!.accessToken == "" {
            self.loginWithSavedCredentials().onError { error in
                print(error)
            }
        }
        if message["request"] as? String == "status" {
            replyHandler(["status" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
        }
        
        if message["request"] as? String == "token" {
            replyHandler(["token" : self.accessTokenLocal!.accessToken ?? ""])
        }
        
        
        if message["request"] as? String == "infos" {
            print("CarId: \(String(describing: SessionHandler.vehicle.id))")
//            self.teslaAPI.getData(self.vehicle.id) { (httpResponse, dataOrNil, errorOrNil) in
//
//                guard let infos = dataOrNil else { return }
//
//                print("Battery is at \(infos.chargeState.batteryLevel)%")
//                replyHandler(["infos" : infos])
//
//                print("Battery is at \(infos.chargeState.batteryLevel)%")
//                print("Temperatur is \(String(describing: infos.climateState.insideTemperature))")
//            }
        }
    }
    
}
