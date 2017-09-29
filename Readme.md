![IoT-Ticket](https://user-images.githubusercontent.com/17162460/27128045-c9c48336-5105-11e7-8eba-8087dab959ec.png)
## IoTTicketSwiftAPI
[![Platforms](https://img.shields.io/cocoapods/p/IoTTicketSwiftAPI.svg)](https://cocoapods.org/pods/IoTTicketSwiftAPI)
[![License](https://img.shields.io/cocoapods/l/IoTTicketSwiftAPI.svg)](https://raw.githubusercontent.com/iDanbo/IoTTicketSwiftAPI/master/LICENSE)

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/IoTTicketSwiftAPI.svg)](https://cocoapods.org/pods/IoTTicketSwiftAPI)

IoT-Ticket REST client in Swift

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Requirements

- iOS 8.0+ / Mac OS X 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build IoTTicketSwiftAPI 0.0.6+.

To integrate IoTTicketSwiftAPI into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'IoTTicketSwiftAPI', '~> 0.0.6'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate IoTTicketSwiftAPI into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "IoTTicketSwiftAPI/IoTTicketSwiftAPI" ~> 0.0.6
```
### Swift Package Manager

To use IoTTicketSwiftAPI as a [Swift Package Manager](https://swift.org/package-manager/) package just add the following in your Package.swift file.

``` swift
import PackageDescription

let package = Package(
    name: "IoTTicketSwiftAPI",
    dependencies: [
        .Package(url: "https://github.com/iDanbo/IoTTicketSwiftAPI.git", "0.0.6")
    ]
)
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate IoTTicketSwiftAPI into your project manually.

#### Git Submodules

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add IoTTicketSwiftAPI as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/iDanbo/IoTTicketSwiftAPI.git
$ git submodule update --init --recursive
```

- Open the new `IoTTicketSwiftAPI` folder, and drag the `IoTTicketSwiftAPI.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `IoTTicketSwiftAPI.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `IoTTicketSwiftAPI.xcodeproj` folders each with two different versions of the `IoTTicketSwiftAPI.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from.

- Select the `IoTTicketSwiftAPI.framework`.

- And that's it!

> The `IoTTicketSwiftAPI.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

#### Embeded Binaries

- Download the latest release from https://github.com/iDanbo/IoTTicketSwiftAPI/releases
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- Add the downloaded `IoTTicketSwiftAPI.framework`.
- And that's it!

## Usage
### Creating a client
```swift
import IoTTicketSwiftAPI

let username = "username"
let password = "password"
let baseURL = "https://my.iot-ticket.com/api/v1/"

let client = IoTTicketClient(baseURL: baseURL, username: username, password: password)
```
### Registering a device
```swift
let device = Device(name: "My iPhone", manufacturer: "Apple", type: "iPhone", deviceDescription: "Device registered with iOS framework", attributes: [deviceAttribute(key: "swift", value: "api"), deviceAttribute(key: "create", value: "apps")])

client.registerDevice(device: device) { deviceDetails, error in
    if let error = error {
        switch error {
            // Handle error
        }
    }
    if let deviceDetails = deviceDetails {
        // Save your device details
    }
}
```
### Sending data
```swift
let latitude = Datanode(name: "Latitude", path: "Location", v: 63.0951)
let longitude = Datanode(name: "Longitude", path: "Location", v: 21.6165)

client.writeDatanode(deviceId: deviceId, datanodes: [latitude, longitude])
```
### Get datanodes for a device
```swift
client.getDatanodes(deviceId: deviceId, limit: 10, offset: 0) { deviceDatanodes, error in
    if let deviceDatanodes = deviceDatanodes {
        // List datanodes
    }
 }
 ```
 ### Read data
 ```swift
let fromDate = dateToTimestamp(date: "2016-02-21 00:00:00")
let toDate = dateToTimestamp(date: "2017-04-11 00:00:00")
        
client.readDatanodes(deviceId: deviceId, criteria: ["latitude", "longitude"], fromDate: fromDate, toDate: toDate, limit: 10000) { datanodeRead, error in
    if let datanodes = datanodeRead?.datanodes {
        // Read datanodes with values
    }
  }
```
### Get devices
```swift
client.getDevices { devicesList, error in
    if let deviceList = deviceList {
        // List your devices
    }
 }
```
### Get a device
```swift
client.getDevice(deviceId: deviceId) { deviceDetails, error in
    if let deviceDetails = deviceDetails {
        // Information for a specific device
    }
 }
```
### Get overall quota
```swift
client.getAllQuota { quota, error in
    if let quota = quota {
        // Your overall quota
    }
 }
```
### Get device specific quota
```swift
client.getDeviceQuota(deviceId: deviceId) { deviceQuota, error in
    if let deviceQuota = deviceQuota {
        // Device specific quota
    }
 }
```
### API documentation
For more information check out the IoT-Ticket REST API documentation
https://www.iot-ticket.com/images/Files/IoT-Ticket.com_IoT_API.pdf. 
## License

IoTTicketSwiftAPI is released under the MIT license. See [LICENSE](https://github.com/iDanbo/IoTTicketSwiftAPI/blob/master/LICENSE) for details.
