//
//  TeslaStreamEndpoint.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 22/04/2017.
//  Copyright © 2017 Joao Nunes. All rights reserved.
//

import Foundation

enum StreamEndpoint {
	
	case stream(email: String, vehicleToken: String, vehicleId: String)
}

extension StreamEndpoint {
	
	var authentication: (email: String, vehicleToken: String) {
		switch self {
		case let .stream(email, vehicleToken, _):
			return (email: email, vehicleToken: vehicleToken)
		}
	}
	var path: String {
		switch self {
		case let .stream(_, _, vehicleId):
			return "/stream/\(vehicleId)/?values=speed,odometer,soc,elevation,est_heading,est_lat,est_lng,power,shift_state,range,est_range,heading"
		}
	}
	
	func baseURL() -> String {
		return "https://streaming.vn.teslamotors.com"
	}
}
