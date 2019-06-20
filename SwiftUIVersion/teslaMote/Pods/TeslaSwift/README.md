# TeslaSwift
Swift library to access Tesla API based on [Tesla JSON API (Unofficial)](https://tesla-api.timdorr.com)

[![Swift](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://swift.org)
[![Build Status](https://travis-ci.org/jonasman/TeslaSwift.svg?branch=master)](https://travis-ci.org/jonasman/TeslaSwift)
[![TeslaSwift](https://img.shields.io/cocoapods/v/TeslaSwift.svg)](https://github.com/jonasman/TeslaSwift)

## Installation

### Manual

Copy `Sources` folder into your project

### CocoaPods

```ruby
pod 'TeslaSwift', '~> 4'
```

### Swift Package Manager

You can use [Swift Package Manager](https://swift.org/package-manager/) and specify a dependency in `Package.swift` by adding this:

```swift
.Package(url: "https://github.com/jonasman/TeslaSwift.git", majorVersion: 4)
```

## Usage

Tesla's server is not fully compatible with ATS so you need to add the following to your app Info.plist

```XML
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

Import the module

```swift
import TeslaSwift
```

Perform an authentication with your My Tesla credentials: 

```swift
let api = TeslaSwift()
api.authenticate(email: email, password: password)
```

Use the promise to check the success: 

```swift
.done { (result) in
    // Logged In!
}.catch { (error) in
    print("Error: \(error as NSError)")
}
```

## Example

```swift

class ViewController {
    func showCars() {
        api.getVehicles()
        .done { (response) in
            self.data = response
            self.tableView.reloadData()
        }.catch { (error) in
            //Process error
   }
}
```

## Streaming

```swift
class ViewController {

  func showStream() {
    api.openStream(vehicle: myVehicle, dataReceived: {
                    (event: StreamEvent?, error: Error?) in

                    if event != nil {
                        self.data.append(event)
                        self.tableView.reloadData()
                    } else {
                        //Process error
                    }
                })

    // After some events...
    api.closeStream()
   }
}
```

## Encoder and Decoder

If you need a JSON Encoder and Decoder, the library provides both already configured to be used with Tesla's JSON formats

```swift
public let teslaJSONEncoder: JSONEncoder
public let teslaJSONDecoder: JSONDecoder
```  

## Options

You can use the mock server by setting: `api.useMockServer = true`

You can enable debugging by setting: `api.debuggingEnabled = true`

## Other Features

After the authentication is done. The library manages itself the access token. 
When the token expires the library will perform another authentication with your past credentials.

## Roadmap
4.x

Add new API features and summon

## Referral

If you want to buy a Tesla or signup for the mailing list using my referral as a "thank you" for this library here it is:
http://ts.la/joao290

## Apps using this library

* Key for Tesla (https://itunes.apple.com/us/app/key-for-tesla/id1202595802?mt=8)
* Camper for Tesla (https://itunes.apple.com/us/app/camper-for-tesla/id1227483065?mt=8)
* Power for Tesla (https://itunes.apple.com/us/app/power-for-tesla/id1194710823?mt=8)
* Plus - for Tesla Model S & X (https://itunes.apple.com/us/app/plus-for-tesla-model-s-x/id1187829197?mt=8)
* Nikola for Tesla (https://itunes.apple.com/us/app/nikola-for-tesla/id1244489779?mt=8)

Missing your app? open a PR or issue

## License

The MIT License (MIT)

Copyright (c) 2016 João Nunes

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
