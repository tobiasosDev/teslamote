//
//  TeslaStreaming.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 23/04/2017.
//  Copyright © 2017 Joao Nunes. All rights reserved.
//

import Foundation

/*
 * Streaming class takes care of the different types of data streaming from Tesla servers
 *
 */
class TeslaStreaming {
	
	var debuggingEnabled = false
	var httpStreaming = HTTPEventStreaming()
	
	func openStream(endpoint: StreamEndpoint, dataReceived: @escaping ((event: StreamEvent?, error: Error?)) -> Void) {
		
		let authentication = endpoint.authentication
		let url = endpoint.baseURL() + endpoint.path
		
		logDebug("Opening Stream to: \(url)", debuggingEnabled: debuggingEnabled)
		
		httpStreaming.openCallback = {
			logDebug("Stream open", debuggingEnabled: self.debuggingEnabled)
		}
		
		httpStreaming.callback = {
			data in
			logDebug("Stream data: \(data)", debuggingEnabled: self.debuggingEnabled)
			
			let event = StreamEvent(values: data)
			
			DispatchQueue.main.async {
				dataReceived((event, nil))
			}
		}
		
		httpStreaming.errorCallback = {
			(error: Error?) in
			
			logDebug("Stream error: \(String(describing: error))", debuggingEnabled: self.debuggingEnabled)
			
			DispatchQueue.main.async {
				dataReceived((nil, error))
			}
		}
		
		httpStreaming.connect(url: URL(string: url)!, username: authentication.email, password: authentication.vehicleToken)
	}
	
	func closeStream() {
		httpStreaming.disconnect()
		logDebug("Stream closed", debuggingEnabled: self.debuggingEnabled)
	}

}
