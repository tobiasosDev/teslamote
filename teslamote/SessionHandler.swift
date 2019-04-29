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
    public let teslaAPI = TeslaAPI()
    public var accessToken = AccessToken()
    
    // 2: Property to manage session
    private var session = WCSession.default
    
    override init() {
        super.init()
        
        // 3: Start and avtivate session if it's supported
        if isSuported() {
            session.delegate = self
            session.activate()
            self.loadAccessToken()
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
    
    func loadAccessToken() {
        if NSUbiquitousKeyValueStore.default.string(forKey: "token") != nil {
            let accessToken: AccessToken = AccessToken()
            accessToken.carId = NSUbiquitousKeyValueStore.default.string(forKey: "carId")!
            accessToken.token = NSUbiquitousKeyValueStore.default.string(forKey: "token")!
            self.accessToken = accessToken;
            self.teslaAPI.setAccessToken(accessToken.token)
        }
    }
    
    /// Observer to receive messages from watch and we be able to response it
    ///
    /// - Parameters:
    ///   - session: session
    ///   - message: message received
    ///   - replyHandler: response handler
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if self.accessToken.token == "" {
            self.loadAccessToken()
        }
        if message["request"] as? String == "status" {
            replyHandler(["status" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
        }
        
        if message["request"] as? String == "token" {
            replyHandler(["token" : self.accessToken.token])
        }
        
        
        if message["request"] as? String == "infos" {
            print("CarId: \(self.accessToken.carId)")
            self.teslaAPI.getData(self.accessToken.carId) { (httpResponse, dataOrNil, errorOrNil) in
                
                guard let infos = dataOrNil else { return }
                
                print("Battery is at \(infos.chargeState.batteryLevel)%")
                replyHandler(["infos" : infos])
                
                print("Battery is at \(infos.chargeState.batteryLevel)%")
                print("Temperatur is \(String(describing: infos.climateState.insideTemperature))")
            }
        }
    }
    
}
