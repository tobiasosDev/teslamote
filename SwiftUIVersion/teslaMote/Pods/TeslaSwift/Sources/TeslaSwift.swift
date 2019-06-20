//
//  TeslaSwift.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 04/03/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation
import PromiseKit
import os.log

public enum RoofState: String, Codable {
	case close
	case vent
}

public enum VehicleCommand {
	case valetMode(valetActivated: Bool, pin: String?)
	case resetValetPin
	case openChargeDoor
	case closeChargeDoor
	case chargeLimitStandard
	case chargeLimitMaxRange
	case chargeLimitPercentage(limit: Int)
	case startCharging
	case stopCharging
	case flashLights
	case honkHorn
	case unlockDoors
	case lockDoors
	case setTemperature(driverTemperature: Double, passengerTemperature: Double)
	case startAutoConditioning
	case stopAutoConditioning
	case setSunRoof(state: RoofState, percentage: Int?)
	case startVehicle(password: String)
	case openTrunk(options: OpenTrunkOptions)
	case togglePlayback
	case nextTrack
	case previousTrack
	case nextFavorite
	case previousFavorite
	case volumeUp
	case volumeDown
	case navigationRequest(options: NavigationRequestOptions)
	case cancelSoftwareUpdate
	case scheduleSoftwareUpdate
	case speedLimitSetLimit(speed: Measurement<UnitSpeed>)
	case speedLimitActivate(pin: String)
	case speedLimitDeactivate(pin: String)
	case speedLimitClearPin(pin: String)
	case setSeatHeater(seat: HeatedSeat, level: HeatLevel)
	case setSteeringWheelHeater(on: Bool)
	case sentryMode(activated: Bool)
	
	func path() -> String {
		switch self {
		case .valetMode:
			return "command/set_valet_mode"
		case .resetValetPin:
			return "command/reset_valet_pin"
		case .openChargeDoor:
			return "command/charge_port_door_open"
		case .closeChargeDoor:
			return "command/charge_port_door_close"
		case .chargeLimitStandard:
			return "command/charge_standard"
		case .chargeLimitMaxRange:
			return "command/charge_max_range"
		case .chargeLimitPercentage:
			return  "command/set_charge_limit"
		case .startCharging:
			return  "command/charge_start"
		case .stopCharging:
			return "command/charge_stop"
		case .flashLights:
			return "command/flash_lights"
		case .honkHorn:
			return "command/honk_horn"
		case .unlockDoors:
			return "command/door_unlock"
		case .lockDoors:
			return "command/door_lock"
		case .setTemperature:
			return "command/set_temps"
		case .startAutoConditioning:
			return "command/auto_conditioning_start"
		case .stopAutoConditioning:
			return "command/auto_conditioning_stop"
		case .setSunRoof:
			return "command/sun_roof_control"
		case .startVehicle:
			return "command/remote_start_drive"
		case .openTrunk:
			return "command/actuate_trunk"
		case .togglePlayback:
			return "command/media_toggle_playback"
		case .nextTrack:
			return "command/media_next_track"
		case .previousTrack:
			return "command/media_prev_track"
		case .nextFavorite:
			return "command/media_next_fav"
		case .previousFavorite:
			return "command/media_prev_fav"
		case .volumeUp:
			return "command/media_volume_up"
		case .volumeDown:
			return "command/media_volume_down"
		case .navigationRequest:
            		return "command/navigation_request"
		case .scheduleSoftwareUpdate:
            		return "command/schedule_software_update"
		case .cancelSoftwareUpdate:
            		return "command/cancel_software_update"
		case .speedLimitSetLimit:
			return "command/speed_limit_set_limit"
		case .speedLimitActivate:
			return "command/speed_limit_activate"
		case .speedLimitDeactivate:
			return "command/speed_limit_deactivate"
		case .speedLimitClearPin:
			return "command/speed_limit_clear_pin"
		case .setSeatHeater:
			return "command/remote_seat_heater_request"
		case .setSteeringWheelHeater:
			return "command/remote_steering_wheel_heater_request"
		case .sentryMode:
			return "command/set_sentry_mode"
		}
	}
}

public enum TeslaError: Error, Equatable {
	case networkError(error:NSError)
	case authenticationRequired
	case authenticationFailed
	case tokenRevoked
	case invalidOptionsForCommand
	case failedToParseData
	case streamingMissingEmailOrVehicleToken
}

let ErrorInfo = "ErrorInfo"
private var nullBody = ""

open class TeslaSwift {
	
	open var useMockServer = false
	open var debuggingEnabled = false {
		didSet {
			streaming.debuggingEnabled = debuggingEnabled
		}
	}
	
	open fileprivate(set) var token: AuthToken?
	
    open fileprivate(set) var email: String?
	fileprivate var password: String?
	lazy fileprivate var streaming = TeslaStreaming()
	
	public init() { }
}

extension TeslaSwift {
	
	public var isAuthenticated: Bool {
		return token != nil && (token?.isValid ?? false)
	}
	
	/**
	Performs the authentition with the Tesla API
	
	You only need to call this once. The token will be stored and your credentials.
	If the token expires your credentials will be reused.
	
	- parameter email:      The email address.
	- parameter password:   The password.
	
	- returns: A Promise with the AuthToken.
	*/

	public func authenticate(email: String, password: String) -> Promise<AuthToken> {
		
		self.email = email
        UserDefaults.standard.set(email, forKey: "TeslaSwift.email")
		self.password = password

		let body = AuthTokenRequest(email: email,
		                            password: password,
		                            grantType: "password",
		                            clientID: "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384",
		                            clientSecret: "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3")
		
		return request(.authentication, body: body)
			.map(on: .global()) { (result: AuthToken) -> AuthToken in
				self.token = result
				return result
			}.recover { (error) -> Guarantee<AuthToken> in

			if case let TeslaError.networkError(error: internalError) = error {
				if internalError.code == 401 {
					throw TeslaError.authenticationFailed
				} else {
					throw error
				}
			} else {
				throw error
			}
		}
	}
	
	
	/**
	Use this method to reuse a previous authentication token
	
	This method is useful if your app wants to ask the user for credentials once and reuse the token skiping authentication
	If the token is invalid a new authentication will be required
	
	- parameter token:      The previous token
	- parameter email:      Email is required for streaming
	*/
	public func reuse(token: AuthToken, email: String? = nil) {
		self.token = token
		self.email = email
	}
	
	/**
	Revokes the stored token. Endpoint always returns true.
	
	- returns: A Promise with the token revoke state.
	*/

	public func revoke() -> Promise<Bool> {
		
		guard let accessToken = self.token?.accessToken else {
			token = nil
			return .value(false)
		}
			
		token = nil
		
		return checkAuthentication().then(on: .global()) {
			(token) -> Promise<BoolResponse> in
			
			let body = ["token" : accessToken]
			self.token = nil
			
			return self.request(.revoke, body: body)
			
			}.map(on: .global()) {
				(data: BoolResponse) -> Bool in
				
				data.response
		}	
	}
	
	/**
	Removes all the information related to the previous authentication
	
	*/
	public func logout() {
		email = nil
		password = nil
		token = nil
	}
	
	/**
	Fetchs the list of your vehicles including not yet delivered ones
	
	- returns: A Promise with an array of Vehicles.
	*/
	public func getVehicles() -> Promise<[Vehicle]> {
		
		return checkAuthentication().then(on: .global()) { _ in
			return self.request(.vehicles, body: nullBody)
			}.map(on: .global()) {
				(data: ArrayResponse<Vehicle>) -> [Vehicle] in
				return data.response
		}
		
	}
	
	public func getAllData(_ vehicle: Vehicle) -> Promise<VehicleExtended> {
		let promise = checkAuthentication()
		let first = promise.then(on: .global()) {
			(token) -> Promise<Response<VehicleExtended>> in
			
			let vehicleID = vehicle.id!
			
			return self.request(.allStates(vehicleID: vehicleID), body: nullBody)
			
		}
		let second = first.map(on: .global()) {
				(data: Response<VehicleExtended>) -> VehicleExtended in
				
				return data.response
		}
		return second
	}
	
	/**
	Fetchs the vehicle mobile access state
	
	- returns: A Promise with mobile access state.
	*/
	public func getVehicleMobileAccessState(_ vehicle: Vehicle) -> Promise<Bool> {
		
		return checkAuthentication().then(on: .global()) {
			(token) -> Promise<BoolResponse> in
			
			let vehicleID = vehicle.id!
			
			return self.request(.mobileAccess(vehicleID: vehicleID), body: nullBody)
			
			}.map(on: .global()) {
				(data: BoolResponse) -> Bool in
				
				data.response
		}
	}
	
	/**
	Fetchs the vehicle charge state
	
	- returns: A Promise with charge state.
	*/
	public func getVehicleChargeState(_ vehicle: Vehicle) -> Promise<ChargeState> {
		
		
		return checkAuthentication().then(on: .global()) {
			(token) -> Promise<Response<ChargeState>> in
			
			let vehicleID = vehicle.id!
			
			return self.request(.chargeState(vehicleID: vehicleID), body: nullBody)
			
			}.map(on: .global()) {
				(data: Response<ChargeState>) -> ChargeState in
				
				data.response
			}
	}
	
	/**
	Fetchs the vehicle Climate state
	
	- returns: A Promise with Climate state.
	*/
	public func getVehicleClimateState(_ vehicle: Vehicle) -> Promise<ClimateState> {
		
		return checkAuthentication().then(on: .global()) {
			(token) -> Promise<Response<ClimateState>> in
			
			let vehicleID = vehicle.id!
			
			return self.request(.climateState(vehicleID: vehicleID), body: nullBody)
				
			}.map(on: .global()) {
				(data: Response<ClimateState>) -> ClimateState in
				
				data.response
			}
	}
	
	/**
	Fetchs the vehicledrive state
	
	- returns: A Promise with drive state.
	*/
	public func getVehicleDriveState(_ vehicle: Vehicle) -> Promise<DriveState> {
		
		return checkAuthentication().then(on: .global()) {
			(token) -> Promise<Response<DriveState>> in
			
			let vehicleID = vehicle.id!
			
			return self.request(.driveState(vehicleID: vehicleID), body: nullBody)
				
			}.map(on: .global()) {
				(data: Response<DriveState>) -> DriveState in
				
					data.response
			}
	}
	
	/**
	Fetchs the vehicle Gui Settings
	
	- returns: A Promise with Gui Settings.
	*/
	public func getVehicleGuiSettings(_ vehicle: Vehicle) -> Promise<GuiSettings> {
		
		return checkAuthentication().then(on: .global()) {
			(token) -> Promise<Response<GuiSettings>> in
			
			let vehicleID = vehicle.id!
			
			return self.request(.guiSettings(vehicleID: vehicleID), body: nullBody)
			
			}.map(on: .global()) {
				(data: Response<GuiSettings>) -> GuiSettings in
				
					data.response
			}
	}
	
	/**
	Fetchs the vehicle state
	
	- returns: A Promise with vehicle state.
	*/
	public func getVehicleState(_ vehicle: Vehicle) -> Promise<VehicleState> {
		
		return checkAuthentication().then(on: .global()) {
			(token) -> Promise<Response<VehicleState>> in
			
			let vehicleID = vehicle.id!
			
			return self.request(.vehicleState(vehicleID: vehicleID), body: nullBody)
			
			}.map(on: .global()) {
				(data: Response<VehicleState>) -> VehicleState in
				
				data.response
		}
	}
	
	/**
	Fetchs the vehicle config
	
	- returns: A Promise with vehicle config
	*/
	public func getVehicleConfig(_ vehicle: Vehicle) -> Promise<VehicleConfig> {
		
		return checkAuthentication().then(on: .global()) {
			(token) -> Promise<Response<VehicleConfig>> in
			
			let vehicleID = vehicle.id!
			
			return self.request(.vehicleConfig(vehicleID: vehicleID), body: nullBody)
			
			}.map(on: .global()) {
				(data: Response<VehicleConfig>) -> VehicleConfig in
				
				data.response
		}
	}
	
	/**
	Wakes up the vehicle
	
	- returns: A Promise with the current Vehicle
	*/
	public func wakeUp(vehicle: Vehicle) -> Promise<Vehicle> {
		
		return checkAuthentication().then(on: .global()) {
			(token) -> Promise<Response<Vehicle>> in
			
			let vehicleID = vehicle.id!
			
			return self.request(.wakeUp(vehicleID: vehicleID), body: nullBody)
			
			}.map(on: .global()) {
				(data: Response<Vehicle>) -> Vehicle in
				
				data.response
		}
	}
	
	
	/**
	Sends a command to the vehicle
	
	- parameter vehicle: the vehicle that will receive the command
	- parameter command: the command to send to the vehicle
	- returns: A Promise with the CommandResponse object containing the results of the command.
	*/
	public func sendCommandToVehicle(_ vehicle: Vehicle, command: VehicleCommand) -> Promise<CommandResponse> {
		
		return checkAuthentication()
			.then(on: .global()) { (token) -> Promise<CommandResponse> in
				
				switch command {
				case let .valetMode(valetActivated, pin):
					let body = ValetCommandOptions(valetActivated: valetActivated, pin: pin)
					return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
				case let .openTrunk(options):
					let body = options
					return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
                case let .navigationRequest(address):
                    let body = address
                    return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
				case let .chargeLimitPercentage(limit):
					let body = ChargeLimitPercentageCommandOptions(limit: limit)
					return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
				case let .setTemperature(driverTemperature, passengerTemperature):
					let body = SetTemperatureCommandOptions(driverTemperature: driverTemperature, passengerTemperature: passengerTemperature)
					return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
				case let .setSunRoof(state, percent):
					let body = SetSunRoofCommandOptions(state: state, percent: percent)
					return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
				case let .startVehicle(password):
					let body = RemoteStartDriveCommandOptions(password: password)
					return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
				case let .speedLimitSetLimit(speed):
					let body = SetSpeedLimitOptions(limit: speed)
					return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
				case let .speedLimitActivate(pin):
					let body = SpeedLimitPinOptions(pin: pin)
					return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
				case let .speedLimitDeactivate(pin):
					let body = SpeedLimitPinOptions(pin: pin)
					return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
				case let .speedLimitClearPin(pin):
					let body = SpeedLimitPinOptions(pin: pin)
					return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
                case let .setSeatHeater(seat, level):
                    let body = RemoteSeatHeaterRequestOptions(seat: seat, level: level)
                    return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
                case let .setSteeringWheelHeater(on):
                    let body = RemoteSteeringWheelHeaterRequestOptions(on: on)
                    return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
                case let .sentryMode(activated):
                    let body = SentryModeCommandOptions(activated: activated)
                    return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: body)
				default:
					return self.request(Endpoint.command(vehicleID: vehicle.id!, command: command), body: nullBody)
				}
		
		}
		
	}
}

extension TeslaSwift {
	
	func checkToken() -> Promise<Bool> {
		
		if let token = self.token {
			return .value(token.isValid)
		} else {
			return .value(false)
		}
	}
	
	func cleanToken() -> Promise<Void> {
		self.token = nil
		return .value(())
	}
	
	func checkAuthentication() -> Promise<AuthToken> {
		
		return checkToken().then(on: .global()) { (value) -> Promise<AuthToken> in
			
			if value {
				return .value(self.token!)
			} else {
				return self.cleanToken().then(on: .global()) {
					_ -> Promise<AuthToken> in
					
					if let email = self.email, let password = self.password {
						return self.authenticate(email: email, password: password)
					} else {
						throw TeslaError.authenticationRequired
					}
				}
				
			}
		}
	}
	
	func request<ReturnType: Decodable, BodyType: Encodable>(_ endpoint: Endpoint, body: BodyType) -> Promise<ReturnType> {
		
		let (promise, seal) = Promise<ReturnType>.pending()
		
		let request = prepareRequest(endpoint, body: body)
		let debugEnabled = debuggingEnabled
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			(data, response, error) in
			
			
			guard error == nil else { seal.reject(error!); return }
			guard let httpResponse = response as? HTTPURLResponse else { seal.reject(TeslaError.failedToParseData); return }
			
			var responseString = "\nRESPONSE: \(String(describing: httpResponse.url))"
			responseString += "\nSTATUS CODE: \(httpResponse.statusCode)"
			if let headers = httpResponse.allHeaderFields as? [String: String] {
				responseString += "\nHEADERS: [\n"
				headers.forEach {(key: String, value: String) in
					responseString += "\"\(key)\": \"\(value)\"\n"
				}
				responseString += "]"
			}
			
			logDebug(responseString, debuggingEnabled: debugEnabled)
			
			if case 200..<300 = httpResponse.statusCode {
				
				do {
					if let data = data {
						let objectString = String.init(data: data, encoding: String.Encoding.utf8) ?? "No Body"
						logDebug("RESPONSE BODY: \(objectString)\n", debuggingEnabled: debugEnabled)
						
						let mapped = try teslaJSONDecoder.decode(ReturnType.self, from: data)
						seal.fulfill(mapped)
					}
				} catch {
					logDebug("ERROR: \(error)", debuggingEnabled: debugEnabled)
					seal.reject(TeslaError.failedToParseData)
				}
				
			} else {
				if let data = data {
					
					let objectString = String.init(data: data, encoding: String.Encoding.utf8) ?? "No Body"
					logDebug("RESPONSE BODY ERROR: \(objectString)\n", debuggingEnabled: debugEnabled)
					
					if let wwwauthenticate = httpResponse.allHeaderFields["Www-Authenticate"] as? String,
						wwwauthenticate.contains("invalid_token") {
						seal.reject(TeslaError.tokenRevoked)
					} else if let mapped = try? teslaJSONDecoder.decode(ErrorMessage.self, from: data) {
						seal.reject(TeslaError.networkError(error: NSError(domain: "TeslaError", code: httpResponse.statusCode, userInfo:[ErrorInfo: mapped])))
					} else {
						seal.reject(TeslaError.networkError(error: NSError(domain: "TeslaError", code: httpResponse.statusCode, userInfo: nil)))
					}
					
				} else {
					if let wwwauthenticate = httpResponse.allHeaderFields["Www-Authenticate"] as? String {
						if wwwauthenticate.contains("invalid_token") {
							seal.reject(TeslaError.authenticationFailed)
						}
					} else {
						seal.reject(TeslaError.networkError(error: NSError(domain: "TeslaError", code: httpResponse.statusCode, userInfo: nil)))
					}
				}
			}
			
			
		}) 
		task.resume()
		
		return promise
	}

	func prepareRequest<BodyType: Encodable>(_ endpoint: Endpoint, body: BodyType) -> URLRequest {
	
		var request = URLRequest(url: URL(string: endpoint.baseURL(useMockServer) + endpoint.path)!)
		request.httpMethod = endpoint.method
		
		request.setValue("TeslaSwift", forHTTPHeaderField: "User-Agent")
		
		if let token = self.token?.accessToken {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		
		if let body = body as? String, body == nullBody {
		} else {
			request.httpBody = try? teslaJSONEncoder.encode(body)
			request.setValue("application/json", forHTTPHeaderField: "content-type")
		}
		
		logDebug("\nREQUEST: \(request)", debuggingEnabled: debuggingEnabled)
		logDebug("METHOD: \(request.httpMethod!)", debuggingEnabled: debuggingEnabled)
		if let headers = request.allHTTPHeaderFields {
			var headersString = "REQUEST HEADERS: [\n"
			headers.forEach {(key: String, value: String) in
				headersString += "\"\(key)\": \"\(value)\"\n"
			}
			headersString += "]"
			logDebug(headersString, debuggingEnabled: debuggingEnabled)
		}
		
		if let body = body as? String, body != nullBody {
		} else if let jsonString = body.jsonString {
			logDebug("REQUEST BODY: \(jsonString)", debuggingEnabled: debuggingEnabled)
		}
		
		return request
	}
	
}

// MARK: Streaming API
extension TeslaSwift {
	
	/**
	Streams vehicle data
	
	- parameter vehicle: the vehicle that will receive the command
	- parameter reloadsVehicle: if you have a cached vehicle, the token might be expired, this forces a vehicle token reload
	- parameter dataReceived: callback to receive the websocket data
	*/
	public func openStream(vehicle: Vehicle, reloadsVehicle: Bool = true, dataReceived: @escaping ((event: StreamEvent?, error: Error?)) -> Void) {
		
		if reloadsVehicle {
			
			reloadVehicle(vehicle: vehicle).done { (freshVehicle) -> Void in
				self.startStream(vehicle: freshVehicle, dataReceived: dataReceived)
			}.catch { (error) in
				dataReceived((event: nil, error: error))
			}
			
		} else {
			startStream(vehicle: vehicle, dataReceived: dataReceived)
		}
	
	}
	
	func reloadVehicle(vehicle: Vehicle) -> Promise<Vehicle> {
		return getVehicles().map { (vehicles: [Vehicle]) -> Vehicle in
			
			for freshVehicle in vehicles where freshVehicle.vehicleID == vehicle.vehicleID {
				return freshVehicle
			}
			
			return vehicle
		}
	}
	
	func startStream(vehicle: Vehicle, dataReceived: @escaping ((event: StreamEvent?, error: Error?)) -> Void) {
		guard let email = email,
			let vehicleToken = vehicle.tokens?.first else {
				dataReceived((nil, TeslaError.streamingMissingEmailOrVehicleToken))
				return
		}
		
		let endpoint = StreamEndpoint.stream(email: email, vehicleToken: vehicleToken, vehicleId: "\(vehicle.vehicleID!)")
		
		streaming.openStream(endpoint: endpoint, dataReceived: dataReceived)
	}

	/**
	Stops the stream
	*/
	public func closeStream() {
		streaming.closeStream()
	}
	
}

func logDebug(_ format: String, debuggingEnabled: Bool) {
	if debuggingEnabled {
		print(format)
	}
}

public let teslaJSONEncoder: JSONEncoder = {
	let encoder = JSONEncoder()
	encoder.outputFormatting = .prettyPrinted
	encoder.dateEncodingStrategy = .secondsSince1970
	return encoder
}()

public let teslaJSONDecoder: JSONDecoder = {
	let decoder = JSONDecoder()
	decoder.dateDecodingStrategy = .secondsSince1970
	return decoder
}()
