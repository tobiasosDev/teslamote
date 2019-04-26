//
//  InterfaceController.swift
//  teslamote WatchKit Extension
//
//  Created by Tobias Lüscher on 26.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    
    // 1: Session property
    private var session = WCSession.default
    @IBOutlet weak var controlsLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // 2: Initialization of session and set as delegate this InterfaceController if it's supported
        if isSuported() {
            session.delegate = self
            session.activate()
        }
        
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
    
    
    

    func getCarInformation() {
        session.sendMessage(["status" : 1], replyHandler: { (response: [String : Any]) in
            controlsLabel.setText(response.)
        }) { (Error) in
            print(Error)
        }
    }

}

extension InterfaceController: WCSessionDelegate {
    
    // 4: Required stub for delegating session
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
}
