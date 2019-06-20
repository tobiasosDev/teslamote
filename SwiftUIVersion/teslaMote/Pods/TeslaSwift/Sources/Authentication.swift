//
//  AuthToken.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 04/03/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

open class AuthToken: Codable {
	
	open var accessToken: String?
	open var tokenType: String?
	open var createdAt: Date? = Date()
	open var expiresIn: TimeInterval?
	open var refreshToken: String?
	
	open var isValid: Bool {
		if let createdAt = createdAt, let expiresIn = expiresIn {
			return -createdAt.timeIntervalSinceNow < expiresIn
		} else {
			return false
		}
	}
	
	public init(accessToken: String) {
		self.accessToken = accessToken
	}
	
	// MARK: Codable protocol
	
	enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case tokenType = "token_type"
		case createdAt = "created_at"
		case expiresIn = "expires_in"
		case refreshToken  = "refresh_token"
	}
}

class AuthTokenRequest: Encodable {
	
	var grantType: String?
	var clientID: String?
	var clientSecret: String?
	var email: String?
	var password: String?
	
	init(email: String, password: String, grantType: String, clientID: String, clientSecret: String) {
		self.email = email
		self.password = password
		self.grantType = grantType
		self.clientID = clientID
		self.clientSecret = clientSecret
	}
	
	// MARK: Codable protocol
	
	enum CodingKeys: String, CodingKey {
		typealias RawValue = String
		
		case grantType = "grant_type"
		case clientID = "client_id"
		case clientSecret = "client_secret"
		case email = "email"
		case password = "password"
	}
}
