//
//  Model.swift
//  IoTTicketSwiftAPI
//
//  Created by Daniel Egerev on 4/18/17.
//  Copyright © 2017 IoTTicket-swift. All rights reserved.
//

import Foundation

/// Your IoT device. Once registered, it will show up under the user's enterprise.
open class Device: NSObject, NSCoding {
    private var _name: String!
    private var _manufacturer: String!
    private var _type: String?
    private var _deviceDescription: String?
    private var _attributes: [Dictionary<String, String>]?
    private var _deviceId: String?
    private var _href: URL?
    private var _createdAt: String?
    
    /**
     Initialze the device with the provided parameters.
     
        - parameters:
     
            - name: A short name for the device
            - manufacturer: Short name for the device’s manufacturer
            - type: The main category the device belongs to
            - devicedDescription: A description of the device: what it does or where it is located
            - attributes: Store additional attributes for the devices
     */
    public init(name: String!, manufacturer: String!, type: String? = nil, deviceDescription: String? = nil, attributes: [Dictionary<String, String>]? = nil) {
        
        self._name = name
        self._manufacturer = manufacturer
        self._type = type
        self._deviceDescription = deviceDescription
        self._attributes = attributes
    }
    
    public override init(){
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self._name = aDecoder.decodeObject(forKey: "name") as! String
        self._manufacturer = aDecoder.decodeObject(forKey: "manufacturer") as! String
        self._type = aDecoder.decodeObject(forKey: "type") as? String
        self._attributes = aDecoder.decodeObject(forKey: "attributes") as? [[String:String]]
        self._deviceId = aDecoder.decodeObject(forKey: "deviceId") as? String
        self._createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
        self._deviceDescription = aDecoder.decodeObject(forKey: "deviceDescription") as? String
        self._href = aDecoder.decodeObject(forKey: "href") as? URL
    }
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.manufacturer, forKey: "manufacturer")
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.attributes, forKey: "attributes")
        aCoder.encode(self.deviceId, forKey: "deviceId")
        aCoder.encode(self.createdAt, forKey: "createdAt")
        aCoder.encode(self.deviceDescription, forKey: "deviceDescription")
        aCoder.encode(self.href, forKey: "href")
    }
    
    /// A short name for the device. Maximum 100 characters.
    public var name: String! {
        get {
            return _name.restrictString(restriction: IoTRestrictions.maxNameLength)
        }
        set {
            _name = newValue
        }
    }
    
    /// Short name for the device’s manufacturer. Maximum 100 characters.
    public var manufacturer: String! {
        get {
            return _manufacturer.restrictString(restriction: IoTRestrictions.maxNameLength)
        }
        set {
            _manufacturer = newValue
        }
    }
    
    /// The main category the device belongs to. Maximum 1000 characters.
    public var type: String? {
        get {
            guard var notNilType = _type else {
                return nil
            }
            return notNilType.restrictString(restriction: IoTRestrictions.maxNameLength)
        }
        set {
            _type = newValue
        }
    }
    
    /// A description of the device: what it does or where it is located. Maximum 255 characters.
    public var deviceDescription: String? {
        get {
            guard var notNilDescription = _deviceDescription else {
                return nil
            }
            return notNilDescription.restrictString(restriction: IoTRestrictions.maxDescriptionLength)
        }
        set {
            _deviceDescription = newValue
        }
    }
    
    /// Contains arrays of key value pairs.
    /// This is used to store additional attributes for the devices as desired by the client.
    /// A maximum of 50 attributes is accepted.
    public var attributes: [Dictionary<String, String>]? {
        get {
            guard var notNilAttributes = _attributes else {
                return nil
            }
            guard notNilAttributes.count <= IoTRestrictions.maxNumberOfAttributes else {
                for index in (IoTRestrictions.maxNumberOfAttributes..<notNilAttributes.count).reversed() {
                    notNilAttributes.remove(at: index)
                }
                return notNilAttributes
            }
            return notNilAttributes
        }
        set {
            _attributes = newValue
        }
    }
    
    /// The ID of the device, to be used in subsequent calls to write and read the device data nodes. It consists of 32 alphanumeric characters.
    public var deviceId: String? {
        get {
            return _deviceId
        }
        set {
            _deviceId = newValue
        }
    }
    
    /// The URL to access the resource.
    public var href: URL? {
        get {
            return _href
        }
        set {
            _href = newValue
        }
    }
    
    /// The time the device was created on the server. The [ISO8601](https://en.wikipedia.org/wiki/ISO_8601) format is used.
    public var createdAt: String? {
        get {
            return _createdAt
        }
        set {
            _createdAt = newValue
        }
    }
    
}

/// Data values are written to the device’s datanodes. Each datanode is identified by its name and the path specified by the client.
/// The datanode is created the first time it is encountered by the server.
/// Intermediate nodes are also created if a path is specified the first time the datanode is encountered.
/// The full path to the datanode should be specified when the datanode is to be read from.
public class Datanode {
    private var _name: String!
    private var _path: String?
    private var _v: Any!
    private var _ts: UInt64?
    private var _unit: String?
    private var _dataType: String?
    private var _href: String?
    
    /**
     Initialze the device with the provided parameters.
     
        - parameters:
     
            - name: A short description of the datanode
            - path: Short name for the device’s manufacturer
            - v: The value to be written. This must be applicable to the datatype, if provided.
            - ts: [Unix Timestamp](https://en.wikipedia.org/wiki/Unix_time). The number of milliseconds since the Epoch. When a timestamp is missing, the current timestamp is automatically used.
            - unit: The unit associated with the data, preferably 1 or 2 characters.
            - dataType: When the datatype is not provided, the possible data type is inferred from the value first received by the server.
     */
    public init(name: String!, path: String? = nil, v: Any!, ts: UInt64? = UInt64(Date().timeIntervalSince1970 * 1000), unit: String? = nil, dataType: String? = nil) {
        self._name = name
        self._path = path
        self._v = v
        self._ts = ts
        self._unit = unit
        self._dataType = dataType
    }
    
    public init() {
        
    }
    
    ///  A short description of the datanode. Maximum 100 characters.
    public var name: String! {
        get {
            
            return _name.restrictString(restriction: IoTRestrictions.maxNameLength)
        }
        
        set {
            _name = newValue
        }
    }
    
    /// Forward slash separates the list of paths to be created to get to the datanode. The path can only consist of a maximum of 10 components.
    public var path: String? {
        get {
            guard var notNilPath = _path else {
                return nil
            }
            return notNilPath.restrictString(restriction: IoTRestrictions.maxPathLength)
        }
        set {
            _path = newValue
        }
    }
    
    /// The value to be written. This must be applicable to the datatype, if provided.
    public var v: Any! {
        get {
            return _v
        }
        set {
            _v = newValue
        }
    }
    
    /// [Unix Timestamp](https://en.wikipedia.org/wiki/Unix_time). The number of milliseconds since the Epoch.
    public var ts: UInt64? {
        get {
            guard let notNilTs = _ts else {
                return UInt64(Date().timeIntervalSince1970 * 1000)
            }
            return notNilTs
        }
        set {
            _ts = newValue
        }
    }
    
    /// The unit associated with the data, preferably 1 or 2 characters. Maximum 10 characters.
    public var unit: String? {
        get {
            guard let notNilUnit = _unit else {
                return nil
            }
            return notNilUnit
        }
        set {
            _unit = newValue
        }
    }
    
    /// Possible values are: long, double, boolean, string or binary.
    public var dataType: String? {
        get {
            return _dataType
        }
        set {
            _dataType = newValue
        }
    }
    /// The URL to read from the datanode targeted in the write.
    public var href: String? {
        get {
            return _href
        }
        set {
            _href = newValue
        }
    }
    
}

/// Used for reading datanodes with values.
public struct DatanodeRead {
    public var name: String!
    public var path: String?
    public var values: [Values]?
    public var unit: String?
    public var dataType: String?
    
    init(){}
}

/// Used for getting a list of datanodes.
public struct DatanodeList {
    public var fullSize: Int? = nil
    public var limit: Int? = nil
    public var offset: Int? = nil
    public var datanodes: [DatanodeInfo]? = nil
}

/// Used to display datanode info from server.
public struct DatanodeInfo {
    public var unit: String!
    public var dataType: String!
    public var href: String!
    public var name: String!
    public var path: String!
}

/// Used for getting a list of devices.
public struct DevicesList {
    public var fullSize: Int? = nil
    public var limit: Int? = nil
    public var offset: Int? = nil
    public var devices: [Device]? = nil
}

/// Used to store write datanode result.
public struct WriteDatanodesResult {
    public var totalWritten: Int? = nil
    public var writeResults: [WriteResults]? = nil
}

/// Used to store writeResults.
public struct WriteResults {
    public var href: String? = nil
    public var writtenCount: Int? = nil
}
/// Used to store quota information.
public struct Quota {
    public var totalDevices:Int! = nil
    public var maxNumberOfDevices:Int! = nil
    public var maxDataNodePerDevice: Int! = nil
    public var usedStorageSize:Int! = nil
    public var maxStorageSize:Int! = nil
}

/// Used to store device quota information
public struct DeviceQuota {
    public var totalRequestToday:Int! = nil
    public var maxReadRequestPerDay:Int! = nil
    public var numberOfDataNodes: Int! = nil
    public var storageSize:Int! = nil
    public var deviceId:String! = nil
}

/// Used to store datanode values
public struct Values {
    public var value: String?
    public var timeStamp: UInt64?
}

/// Used for parsing value and timestamp in reading datanode
public enum ValueTimeStamp: String {
    case value = "v"
    case timeStamp = "ts"
}

/// Data type values *double, long, string, boolean, binary* with their associated values of type String respectively.
public enum DataType: String {
    case double = "double"
    case long = "long"
    case string = "string"
    case boolean = "boolean"
    case binary = "binary"
}

/// Ordering of results for read process data queries
public enum Order: String {
    case ascending = "ascending"
    case descending = "descending"
}

extension Device {
    /// Convert to dictionary
    public func toDict() -> [String : Any] {
        var dict : [String:Any] = [:]
        dict["name"] = self.name
        dict["manufacturer"] = self.manufacturer
        dict["type"] = self.type
        dict["description"] = self.deviceDescription
        dict["attributes"] = self.attributes
        return dict as [String : Any]
    }
}

extension String {
    /// Function to remove number of characters
    public mutating func restrictString(restriction: Int) -> String {
        guard self.characters.count <= restriction else {
            return String(self.characters.prefix(restriction))
        }
        return self
    }
}

