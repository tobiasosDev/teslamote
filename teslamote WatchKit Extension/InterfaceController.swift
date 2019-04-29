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

class InterfaceController: WKInterfaceController {
    static var token = ""
    private let teslaAPI = TeslaAPI()
    private var vehicle: Vehicle = Vehicle()
    @IBOutlet weak var controllsLabel: WKInterfaceLabel!
    @IBOutlet weak var temperaturLabel: WKInterfaceLabel!
    @IBOutlet weak var chargingLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var locationLabel: WKInterfaceLabel!
    @IBOutlet weak var lockOpenLabel: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
    }
    
    override func didAppear() {
        self.getAccessToken()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func openTrunk(_ sender: Any) {
        teslaAPI.send(.openTrunk, to: vehicle) { (repsonse) in
            if repsonse.result {
                self.getCarInformation()
            }
        }
    }
    
    
    @IBAction func openCar(_ sender: Any) {
        let command = self.vehicle.vehicleState.locked ? Command.unlockDoors : Command.lockDoors
        
        teslaAPI.send(command, to: vehicle) { (repsonse) in
            if repsonse.result {
                self.getCarInformation()
            }
        }
    }
    
    func getAccessToken() {
        session.sendMessage(["request" : "token"], replyHandler: { (response: [String : Any]) in
            self.token = (response.first(where: {$0.key == "token"})?.value as! String)
            self.teslaAPI.setAccessToken(self.token)
            
            self.teslaAPI.getVehicles { (httpResponse, dataOrNil, errorOrNil) in
                
                self.vehicle = (dataOrNil?.vehicles.first)!
                
                print("Hello, \(self.vehicle.displayName)")
                print("id: \(self.vehicle.id)")
                print("vhicleid: \(self.vehicle.vehicleId)")
                self.teslaAPI.wake(self.vehicle, completion: { (res, _, err) in
                    
                    guard res else { return }
                    self.getCarInformation()
                })
            }
        }) { (Error) in
            print(Error)
        }
    }
    
    func getCarInformation() {
       
            
            self.teslaAPI.getData(for: self.vehicle, completion: { (res, data, err) in
                self.vehicle = data!
                self.controllsLabel.setText("Trunk \(self.vehicle.vehicleState.isRearTrunkOpen ? "open" : "closed" )")
                self.temperaturLabel.setText("Innen \(String(describing: self.vehicle.climateState.insideTemperature!)) °C")
                self.chargingLabel.setText("Charged: \(self.vehicle.chargeState.batteryLevel )%")
                self.distanceLabel.setText(String(self.vehicle.chargeState.estBatteryRange))
                self.lockOpenLabel.setText(self.vehicle.vehicleState.locked ? "Öffnen" : "Schliessen")
                // self.locationLabel.setText(vehicleInfo.driveState.)
            })
        
    }
    
    
}

extension InterfaceController: WCSessionDelegate {
    
    // 4: Required stub for delegating session
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
}
