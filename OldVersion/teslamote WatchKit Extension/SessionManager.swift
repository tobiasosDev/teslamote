//
//  SessionManager.swift
//  teslamote WatchKit Extension
//
//  Created by Tobias Lüscher on 29.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//
import WatchKit
import WatchConnectivity
import TeslaKit

class SessionManger: NSObject {
    static var token: String = ""
    static var vehicle: Vehicle = Vehicle()
}
