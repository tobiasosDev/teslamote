//
//  SessionHandler.swift
//  teslamote
//
//  Created by Tobias Lüscher on 26.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//


import Foundation
import WatchConnectivity
import TeslaKit

class SessionHandler : NSObject, WCSessionDelegate {
    
    // 1: Singleton
    static let shared = SessionHandler()
    public var vehicle = Vehicle()
    public var vehicles = [Vehicle]()
    public var accessTokenLocal = AccessToken.Response()
    public let teslaAPI = TeslaAPI()
    
    // 2: Property to manage session
    private var session = WCSession.default
    
    override init() {
        super.init()
        
        // 3: Start and avtivate session if it's supported
        if isSuported() {
            session.delegate = self
            session.activate()
            self.loginWithSavedCredentials()
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
    
    func login(username: String, password: String) {
        NSUbiquitousKeyValueStore.default.set(username, forKey: "username")
        NSUbiquitousKeyValueStore.default.set(password, forKey: "password")
        
        teslaAPI.getAccessToken(email: username, password: password) { (httpResponse, dataOrNil, errorOrNil) in
            guard let accessToken = dataOrNil else { return }
            
            self.accessTokenLocal = accessToken
            self.setAccessToken(accessToken: self.accessTokenLocal.accessToken!)
            // self.performSegue(withIdentifier: "goToMain", sender: nil)
        }
    }
    
    func loginWithSavedCredentials() {
        if self.hasLoginCredentials() {
            let username = NSUbiquitousKeyValueStore.default.string(forKey: "username")
            let password = NSUbiquitousKeyValueStore.default.string(forKey: "password")
            self.login(username: username!, password: password!)
        } else {
            
        }
    }
    
    func hasLoginCredentials() -> Bool {
        NSUbiquitousKeyValueStore.default.synchronize()
        return (NSUbiquitousKeyValueStore.default.string(forKey: "username") != nil && NSUbiquitousKeyValueStore.default.string(forKey: "username") != "") && (NSUbiquitousKeyValueStore.default.string(forKey: "password") != nil && NSUbiquitousKeyValueStore.default.string(forKey: "password") != "")
    }
    
    func refreshToken() {
        if self.accessTokenLocal.isExpired {
            self.teslaAPI.getRefreshToken(self.accessTokenLocal.refreshToken!) { (httpResponse, dataOrNil, errorOrNil) in
                if httpResponse.statusCode == 200 {
                    self.accessTokenLocal = dataOrNil!
                }
            }
        }
    }
    
    func setAccessToken(accessToken: String) {
        // SessionHandler.shared.teslaAPI.setAccessToken(accessToken)
        self.teslaAPI.setAccessToken(accessToken)
        
        self.teslaAPI.getVehicles { (httpResponse, dataOrNil, errorOrNil) in
            
            guard let vehicles = dataOrNil?.vehicles else { return }
            self.vehicles = vehicles
            self.vehicle = self.vehicles.first!
            
            print("Hello, \(self.vehicle.displayName)")
            let accessTokenModel = AccessTokenModel()
            accessTokenModel.token = accessToken;
            accessTokenModel.carId = "\(self.vehicle.id)"
            
            print("id: \(self.vehicle.id)")
            print("vhicleid: \(self.vehicle.vehicleId)")
            
            // SessionHandler.shared.accessToken = accessTokenModel
            
        }
        
    }
    
    /// Observer to receive messages from watch and we be able to response it
    ///
    /// - Parameters:
    ///   - session: session
    ///   - message: message received
    ///   - replyHandler: response handler
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if self.accessTokenLocal.accessToken == "" {
            self.loginWithSavedCredentials()
        }
        if message["request"] as? String == "status" {
            replyHandler(["status" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
        }
        
        if message["request"] as? String == "token" {
            replyHandler(["token" : self.accessTokenLocal.accessToken])
        }
        
        
        if message["request"] as? String == "infos" {
            print("CarId: \(self.vehicle.id)")
            self.teslaAPI.getData(self.vehicle.id) { (httpResponse, dataOrNil, errorOrNil) in
                
                guard let infos = dataOrNil else { return }
                
                print("Battery is at \(infos.chargeState.batteryLevel)%")
                replyHandler(["infos" : infos])
                
                print("Battery is at \(infos.chargeState.batteryLevel)%")
                print("Temperatur is \(String(describing: infos.climateState.insideTemperature))")
            }
        }
    }
    
}
