//
//  LocationController.swift
//  teslamote WatchKit Extension
//
//  Created by Tobias Lüscher on 30.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import WatchKit
import Foundation
import TeslaKit


class LocationController: WKInterfaceController {
    @IBOutlet weak var mapObject: WKInterfaceMap!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let mapLocation = CLLocationCoordinate2DMake(SessionManger.vehicle.driveState.latitude, SessionManger.vehicle.driveState.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        let region = MKCoordinateRegion(center: mapLocation, span: span)
        self.mapObject.setRegion(region)
        
        self.mapObject.addAnnotation(mapLocation, with: .red)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
