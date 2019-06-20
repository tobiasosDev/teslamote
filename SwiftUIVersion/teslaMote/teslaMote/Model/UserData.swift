/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A model object that stores app data.
*/

import SwiftUI
import Combine
import TeslaSwift

let demoJson = """
{
      "id": 12345678901234567,
      "vehicle_id": 1234567890,
      "vin": "5YJSA11111111111",
      "display_name": "Nikola 2.0",
      "option_codes": "MDLS,RENA,AF02,APF1,APH2,APPB,AU01,BC0R,BP00,BR00,BS00,CDM0,CH05,PBCW,CW00,DCF0,DRLH,DSH7,DV4W,FG02,FR04,HP00,IDBA,IX01,LP01,ME02,MI01,PF01,PI01,PK00,PS01,PX00,PX4D,QTVB,RFP2,SC01,SP00,SR01,SU01,TM00,TP03,TR00,UTAB,WTAS,X001,X003,X007,X011,X013,X021,X024,X027,X028,X031,X037,X040,X044,YFFC,COUS",
      "color": null,
      "tokens": ["abcdef1234567890", "1234567890abcdef"],
      "state": "offline",
      "in_service": false,
      "id_s": "12345678901234567",
      "calendar_enabled": true,
      "api_version": 4,
      "backseat_token": null,
      "backseat_token_updated_at": null
    }
""".data(using: .utf8)!

let decoder = JSONDecoder()
let demoVehicle = try! decoder.decode(VehicleExtended.self, from: demoJson)

final class UserData: BindableObject {
    let didChange = PassthroughSubject<UserData, Never>()
    
    var currentVehicle: VehicleExtended = demoVehicle {
        didSet {
            didChange.send(self)
        }
    }
    
    func updateVehicleData() {
        TeslaComHandler.updateCarInformation(vehicle: SessionHandler.vehicle).onSuccess { newVehicle in
            self.currentVehicle = newVehicle
        }
    }
}
