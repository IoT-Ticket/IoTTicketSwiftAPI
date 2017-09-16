//
//  Model.swift
//  IoTTicketSwiftAPI
//
//  Created by Daniel Egerev on 4/18/17.
//  Copyright © 2017 IoTTicket-swift. All rights reserved.
//

import Foundation

/// Your IoT device. Once registered, it will show up under the user's enterprise.
public class Device: Codable {
    private var _name: String
    private var _manufacturer: String
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
    public init(name: String, manufacturer: String, type: String? = nil, deviceDescription: String? = nil, attributes: [Dictionary<String, String>]? = nil) {
        
        self._name = name
        self._manufacturer = manufacturer
        self._type = type
        self._deviceDescription = deviceDescription
        self._attributes = attributes
    }
    
    /// A short name for the device. Maximum 100 characters.
    public var name: String {
        get {
            return _name.restrictString(restriction: IoTRestrictions.maxNameLength)
        }
        set {
            _name = newValue
        }
    }
    
    /// Short name for the device’s manufacturer. Maximum 100 characters.
    public var manufacturer: String {
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
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self._name = try values.decode(String.self, forKey: .name)
        self._manufacturer = try values.decode(String.self, forKey: .manufacturer)
        self._type = try? values.decode(String.self, forKey: .type)
        self._attributes = try? values.decode([[String:String]].self, forKey: .attributes)
        self._deviceId = try values.decode(String.self, forKey: .deviceId)
        self._createdAt = try? values.decode(String.self, forKey: .createdAt)
        self._deviceDescription = try? values.decode(String.self, forKey: .deviceDescription)
        self._href = try? values.decode(URL.self, forKey: .href)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.manufacturer, forKey: .manufacturer)
        try container.encodeIfPresent(self.attributes, forKey: .attributes)
        try container.encodeIfPresent(self.type, forKey: .type)
        try container.encodeIfPresent(self.deviceId, forKey: .deviceId)
        try container.encodeIfPresent(self.createdAt, forKey: .createdAt)
        try container.encodeIfPresent(self.deviceDescription, forKey: .deviceDescription)
        try container.encodeIfPresent(self.href, forKey: .href)
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case manufacturer
        case type
        case attributes
        case deviceId
        case createdAt
        case deviceDescription = "description"
        case href
    }
    
}

/// Data values are written to the device’s datanodes. Each datanode is identified by its name and the path specified by the client.
/// The datanode is created the first time it is encountered by the server.
/// Intermediate nodes are also created if a path is specified the first time the datanode is encountered.
/// The full path to the datanode should be specified when the datanode is to be read from.
public class Datanode: Encodable {
    private var _name: String
    private var _path: String?
    private var _v: Any
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
    public init(name: String, path: String? = nil, v: Any, ts: UInt64? = UInt64(Date().timeIntervalSince1970 * 1000), unit: String? = nil, dataType: String? = nil) {
        self._name = name
        self._path = path
        self._v = v
        self._ts = ts
        self._unit = unit
        self._dataType = dataType
    }
    
    ///  A short description of the datanode. Maximum 100 characters.
    public var name: String {
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
    public var v: String {
        get {
            return String(describing: _v)
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
    
    private enum CodingKeys: String, CodingKey {
        case name
        case path
        case v
        case ts
        case unit
        case dataType
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.v, forKey: .v)
        try container.encodeIfPresent(self.path, forKey: .path)
        try container.encodeIfPresent(self.ts, forKey: .ts)
        try container.encodeIfPresent(self.unit, forKey: .unit)
        try container.encodeIfPresent(self.dataType, forKey: .dataType)
    }
    
}

/// Used for reading datanodes with values.
public struct DatanodeRead: Codable {
    public var href: URL
    public var datanodeReads: [Datanodes]?
}

public struct Datanodes: Codable {
    public var name: String!
    public var path: String?
    public var values: [Values]?
    public var unit: String?
    public var dataType: String?
}

/// Used for getting a list of datanodes.
public struct DatanodeList: Codable {
    public var fullSize: Int
    public var limit: Int
    public var offset: Int
    public var datanodes: [DatanodeInfo]?
    
    private enum CodingKeys: String, CodingKey {
        case fullSize
        case limit
        case offset
        case datanodes = "items"
    }
}

/// Used to display datanode info from server.
public struct DatanodeInfo: Codable {
    public var unit: String?
    public var dataType: String?
    public var href: String!
    public var name: String!
    public var path: String?
}

/// Used for getting a list of devices.
public struct DevicesList: Codable {
    public var fullSize: Int? = nil
    public var limit: Int? = nil
    public var offset: Int? = nil
    public var devices: [Device]? = nil
    
    private enum CodingKeys: String, CodingKey {
        case fullSize
        case limit
        case offset
        case devices = "items"
    }
}

/// Used to store write datanode result.
public struct WriteDatanodesResult: Codable {
    public var totalWritten: Int? = nil
    public var writeResults: [WriteResults]? = nil
}

/// Used to store writeResults.
public struct WriteResults: Codable {
    public var href: String? = nil
    public var writtenCount: Int? = nil
}
/// Used to store quota information.
public struct Quota: Codable {
    public var totalDevices:Int! = nil
    public var maxNumberOfDevices:Int! = nil
    public var maxDataNodePerDevice: Int! = nil
    public var usedStorageSize: Int! = nil
    public var maxStorageSize: Int! = nil
}

/// Used to store device quota information
public struct DeviceQuota: Codable {
    public var totalRequestToday:Int! = nil
    public var maxReadRequestPerDay:Int! = nil
    public var numberOfDataNodes: Int! = nil
    public var storageSize: Int! = nil
    public var deviceId: String! = nil
}

/// Used to store datanode values
public struct Values: Codable {
    public var value: String
    public var timeStamp: UInt64
    
    private enum CodingKeys: String, CodingKey {
        case value = "v"
        case timeStamp = "ts"
    }
}

internal struct IoTError: Codable {
    var description: String
    var code: Int
    var moreInfo: String
    var apiver: Int
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

extension String {
    /// Function to remove number of characters
    public mutating func restrictString(restriction: Int) -> String {
        guard self.characters.count <= restriction else {
            return String(self.characters.prefix(restriction))
        }
        return self
    }
}

