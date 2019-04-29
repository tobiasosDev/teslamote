//
//  SessionManager.swift
//  teslamote WatchKit Extension
//
//  Created by Tobias Lüscher on 29.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//
import WatchKit
import WatchConnectivity

class SessionManger: NSObject, WCSessionDelegate {
    // 1: Session property
    private var session = WCSession.default
    
    static func initial() {
        if isSuported() {
            session.delegate = self
            session.activate()
        }
    }
    
    private func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
}
