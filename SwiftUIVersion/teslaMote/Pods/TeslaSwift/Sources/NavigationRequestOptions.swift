//
//  NavigationRequestOptions.swift
//  TeslaSwift
//
//  Created by Derek Johnson on 10/14/18.
//

import Foundation

open class NavigationRequestOptions: Codable {
	
	public let type: String
    public let value: NavigationRequestValue
    public let locale: String
    public let timestamp_ms: String
    
    public init(address: String) {
        self.value = NavigationRequestValue.init(address: address)
        self.type = "share_ext_content_raw"
        self.locale = "en-US"
        self.timestamp_ms = "12345"
    }
	
    public class NavigationRequestValue: Codable {
		
		public let intentAction: String
        public let intentType: String
        public let intentText: String
		
        init(address: String) {
            self.intentText = "Place Name\n\(address)\n(123) 123-1234\nhttps://maps.google.com/?cid=12345"
            self.intentAction = "android.intent.action.SEND"
            self.intentType = "text%2F%0Aplain"
        }
		
        enum CodingKeys: String, CodingKey {
            case intentAction   = "android.intent.ACTION"
            case intentType     = "android.intent.TYPE"
            case intentText     = "android.intent.extra.TEXT"
        }
    }
}
