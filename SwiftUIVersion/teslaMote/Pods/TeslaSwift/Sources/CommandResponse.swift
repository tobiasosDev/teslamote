//
//  CommandResponse.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 05/04/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

open class CommandResponse: Decodable {
	
	private struct Response: Decodable {
		var result: Bool?
		var reason: String?
	}
	private var response: Response
	
	open var result: Bool? { return response.result }
	open var reason: String? { return response.reason }
	
	init() {
		response = Response()
	}
	
	enum CodingKeys: String, CodingKey {
		case response
	}
	
	required public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		response = (try? container.decode(Response.self, forKey: .response)) ?? Response()
		
	}
}
