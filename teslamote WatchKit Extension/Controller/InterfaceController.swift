//
//  InterfaceController.swift
//  teslamote WatchKit Extension
//
//  Created by Tobias Lüscher on 26.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import WatchKit
import Foundation
import TeslaKit
import WatchConnectivity
import EMTLoadingIndicator

class InterfaceController: WKInterfaceController {
    // 1: Session property
    private var session = WCSession.default
    private let teslaAPI = TeslaAPI()
    private var indicator: EMTLoadingIndicator?
    @IBOutlet weak var controllsLabel: WKInterfaceLabel!
    @IBOutlet weak var temperaturLabel: WKInterfaceLabel!
    @IBOutlet weak var chargingLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var locationLabel: WKInterfaceLabel!
    @IBOutlet weak var lockOpenLabel: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        if isSuported() {
            session.delegate = self
            session.activate()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didAppear() {
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    @IBAction func openTrunk(_ sender: Any) {
        teslaAPI.send(.openTrunk, to: SessionManger.vehicle) { (repsonse) in
            if repsonse.result {
                self.getCarInformation()
            }
        }
    }
    
    
    @IBAction func openCar(_ sender: Any) {
        let command = SessionManger.vehicle.vehicleState.locked ? Command.unlockDoors : Command.lockDoors
        
        teslaAPI.send(command, to: SessionManger.vehicle) { (repsonse) in
            if repsonse.result {
                self.getCarInformation()
            }
        }
    }
    
    @IBAction func goToControlsPage(_ sender: Any) {
        pushController(withName: "controlsController", context: nil)
    }
    
    @IBAction func goToChargingPage(_ sender: Any) {
        pushController(withName: "chargingController", context: nil)
    }
    
    @IBAction func goToLocationPage(_ sender: Any) {
        pushController(withName: "locationController", context: nil)
    }
    
    func getAccessToken() {
        print("start")
        session.sendMessage(["request" : "token"], replyHandler: { (response: [String : Any]) in
            print("session token")
            SessionManger.token = (response.first(where: {$0.key == "token"})?.value as! String)
            self.teslaAPI.setAccessToken(SessionManger.token)
            print("session token set")
            self.teslaAPI.getVehicles { (httpResponse, dataOrNil, errorOrNil) in
                
                print("vehicle get")
                
                SessionManger.vehicle = (dataOrNil?.vehicles.first)!
                print("Hello, \(SessionManger.vehicle.displayName)")
                print("id: \(SessionManger.vehicle.id)")
                print("vhicleid: \(SessionManger.vehicle.vehicleId)")
                if (SessionManger.vehicle.status != VehicleStatus.online) {
                    self.teslaAPI.wake(SessionManger.vehicle, completion: { (res, _, err) in
                        
                        guard res else { return }
                        print("finished wake")
                        self.getCarInformation()
                    })
                } else {
                    self.getCarInformation()
                }
            }
        }) { (Error) in
            print(Error)
        }
    }
    
    func getCarInformation() {
       
            
            self.teslaAPI.getData(for: SessionManger.vehicle, completion: { (res, data, err) in
                SessionManger.vehicle = data!
                self.controllsLabel.setText("Trunk \(SessionManger.vehicle.vehicleState.isRearTrunkOpen ? "open" : "closed" )")
                self.temperaturLabel.setText("Innen \(String(describing: SessionManger.vehicle.climateState.insideTemperature!)) °C")
                self.chargingLabel.setText("Charged: \(SessionManger.vehicle.chargeState.batteryLevel )%")
                self.distanceLabel.setText(String((SessionManger.vehicle.chargeState.estBatteryRange * 1.609344).rounded()))
                self.lockOpenLabel.setText(SessionManger.vehicle.vehicleState.locked ? "Öffnen" : "Schliessen")
                print("finished Data")
                // self.locationLabel.setText(vehicleInfo.driveState.)
            })
        
    }
    
    
}

extension InterfaceController: WCSessionDelegate {
    
    // 4: Required stub for delegating session
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if (SessionManger.token == "") {
            self.getAccessToken()
        } else {
            getCarInformation()
        }
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
}
