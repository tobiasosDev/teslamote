//
//  AccessToken.swift
//  teslamote
//
//  Created by Tobias Lüscher on 26.04.19.
//  Copyright © 2019 Tobias Lüscher. All rights reserved.
//

import Foundation
import RealmSwift


class AccessToken: Object {
    @objc dynamic var token = ""
}
