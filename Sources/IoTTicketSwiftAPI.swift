//
//  IoTTicketSwiftAPI.swift
//  IoTTicketSwiftAPI
//
//  Created by Daniel Egerev on 4/18/17.
//  Copyright © 2017 IoTTicket-swift. All rights reserved.
//

import Foundation

/// A closure executed when the function which returns deviceDetails is complete
public typealias DownloadedDeviceDetails = (_ deviceDetails: Device?, _ error: IoTServerError?) -> ()
/// A closure executed when the function which returns deviceDetailsArray is complete
public typealias DownloadedDeviceDetailsArray = (_ deviceDetailsArray: DevicesList?, _ error: IoTServerError?) -> ()
/// A closure executed when the function which returns deviceDatanodes is complete
public typealias DownloadedDeviceDatanodes = (_ deviceDatanodes: DatanodeList?, _ error: IoTServerError?) -> ()
/// A closure executed when the function which returns datanodeRead is complete
public typealias DownloadedDeviceDatanodeRead = (_ datanodeRead: [DatanodeRead]?, _ error: IoTServerError?) -> ()
/// A closure executed when the function which returns quota is complete
public typealias DownloadedAllQuota = (_ quota: Quota?, _ error: IoTServerError?) -> ()
/// A closure executed when the function which returns deviceQuota is complete
public typealias DownloadedDeviceQuota = (_ deviceQuota: DeviceQuota?, _ error: IoTServerError?) -> ()
/// A closure executed when the function which returns writeDatanodesResult is complete
public typealias DownloadedWriteDatanodes = (_ writeDatanodesResult: WriteDatanodesResult?, _ error: IoTServerError?) -> ()
/// A closure executed when the function which returns an object is complete
public typealias DownloadedData = (_ success: Bool, _ object: Any?) -> ()

// MARK: - IoT-Ticket API Client

/// Main client with provided methods. For more information download the [IoT-Ticket API Developement Guide](https://www.iot-ticket.com/images/Files/IoT-Ticket.com_IoT_API.pdf)
open class IoTTicketClient {
    
    /// The username registered on my.iot-ticket.com
    public var username: String
    /// Password for the account
    public var password: String
    private var _baseURL: String
    
    /**
     Initializes the client with the provided parameters.
     
     - parameters:
     
        - username: The username registered on my.iot-ticket.com
        - password: Password for the account
        - baseURL: URL to which the API calls are to be made
     */
    
    public init(baseURL: String, username: String, password: String) {
        self._baseURL = baseURL
        self.username = username
        self.password = password
    }
    
    /// URL to which the API calls are to be made.
    public var baseURL: String {
        get {
            // Add forward slash from URL string if absent
            if _baseURL.characters.last != "/"
            {
                return _baseURL + "/"
            } else {
                return _baseURL
            }
        }
        set {
            _baseURL = newValue
        }
    }
    
    /// Credentials for basic authentication.
    private var credentials: String {
        return "\(username):\(password)".data(using: .utf8)!.base64EncodedString(options: [])
    }
    
    /// URL path to devices
    private var deviceResource: String { return "devices/" }
    
    // MARK: - Provided methods
    
    /**
     Writes an array of datanodes values to a device.
     
     - parameters:
     
        - deviceId: The id of the device, to be used in subsequent calls to write and read the device data nodes. It consists of 32 alphanumeric characters.
        - datanodes: Array of datanodes object.
        - completion: A closure which is called with writeDatanodesResult (WriteDatanodesResult object) and error (IoTServerError) if any.
     */
    
    open func writeDatanode(deviceId: String, datanodes: [Datanode], completion: DownloadedWriteDatanodes? = nil) {
        /// URL path to write data
        var writeDataResourceFormat: String { return "process/write/\(deviceId)/" }
        // Convert to array of dictionaries
        let datanodesToDict = datanodes.map { datanode in
            return [
                
                "name": datanode.name,
                "path": datanode.path as Any,
                "v": datanode.v,
                "ts": datanode.ts as Any,
                "unit": datanode.unit as Any,
                "dataType": datanode.dataType as Any
            ]
        }
        post(request: clientURLRequest(path: writeDataResourceFormat, params: datanodesToDict, credentials: credentials)) { (success, object) -> () in
            guard let completion = completion else { return }
            DispatchQueue.main.async() { () -> Void in
                if success {
                    if let json = object as? Dictionary<String, AnyObject> {
                        var writeDatanodesResult = WriteDatanodesResult()
                        writeDatanodesResult.totalWritten = json["totalWritten"] as? Int
                        if let writeResults = json["writeResults"] as? [Dictionary<String, Any>] {
                            writeDatanodesResult.writeResults = writeResults.map { result -> WriteResults in
                                var singleWriteResult = WriteResults()
                                singleWriteResult.href = result["href"] as? String
                                singleWriteResult.writtenCount = result["writtenCount"] as? Int
                                return singleWriteResult
                            }
                        }
                        completion(writeDatanodesResult, nil)
                    }
                } else {
                    completion(nil, getErrorInfo(object: object) as IoTServerError?)
                }
            }
        }
        
    }
    
    /**
     Reads specific datanodes.
     
     - parameters:
     
        - deviceId: The id of the device from where to read the device data nodes. It consists of 32 alphanumeric characters.
        - criteria: The path to datanodes and the datanode names. Maximum 10 datanodes.
        - fromDate: The number of milliseconds since the Epoch. It defines the time from which the data is obtained. It should be provided, if there is a todate.
        - toDate: The number of milliseconds since the Epoch. It defines the time to which the data read ends. It defaults to the current time if this value is not provided and a fromdate exists. If neither the fromdate and todate are provided, the latest value is returned.
        - limit: The maximum number of data points returned for each datanode queried.
        - order: It orders the values by timestamp, in either ascending or descending order.
        - completion: A closure which is called with datanodeReadArray (array of DatanodeRead object) and error (IoTServerError) if any.
     */
    
    open func readDatanodes(deviceId: String, criteria: [String], fromDate: UInt64? = nil, toDate: UInt64? = nil, limit: Int = 1000, order: Order = Order.ascending, completion: @escaping DownloadedDeviceDatanodeRead) {
        /// URL path to read data
        var readDataResourceFormat: String { return "process/read/\(deviceId)" }
        /// URL path to datanodes
        var datanodes: String {
            let maxCriteria = criteria.prefix(10)
            let mutatedCriteria = maxCriteria.map { string in return string.replacingOccurrences(of: " ", with: "%20") }.joined(separator: ",")
            return "?datanodes=\(mutatedCriteria)"
        }
        /// fromDate URL path
        var pathFromDate: String {
            guard let notNilFromDate = fromDate else {
                return ""
            }
            return "&fromdate=\(notNilFromDate)"
        }
        /// toDate URL path
        var pathToDate: String {
            guard let notNilToDate = toDate else {
                return ""
            }
            return "&todate=\(notNilToDate)"
        }
        /// limit URL path
        var pathLimit: String {
            guard limit < 10000 else {
                let maxLimit = 10000
                return "&limit=\(maxLimit)"
            }
            return "&limit=\(limit)"
        }
        /// order URL path
        var pathOrder: String {
            return "&order=\(order.rawValue)"
        }
        /// Full path for the request
        let path = readDataResourceFormat + datanodes + pathFromDate + pathToDate + pathLimit + pathOrder
        
        get(request: clientURLRequest(path: path, credentials: credentials)) { (success, object) -> () in
            DispatchQueue.main.async() { () -> Void in
                if success {
                    if let json = object as? Dictionary<String, AnyObject> {
                        if let datanodeReads = json["datanodeReads"] as? Array<Dictionary<String, AnyObject>> {
                            var datanode = DatanodeRead()
                            let datanodeReadArray: Array<DatanodeRead> = datanodeReads.map { singleDatanode in
                                datanode.dataType = singleDatanode["dataType"] as? String
                                datanode.name = singleDatanode["name"] as? String
                                datanode.path = singleDatanode["path"] as? String
                                datanode.unit = singleDatanode["unit"] as? String
                                if let valuesAsDict = singleDatanode["values"] as? [Dictionary<String, Any>] {
                                    datanode.values = valuesAsDict.map { vts in
                                        var tempValueTimestamp = Values()
                                        tempValueTimestamp.value = vts[ValueTimeStamp.value.rawValue]! as? String
                                        tempValueTimestamp.timeStamp = vts[ValueTimeStamp.timeStamp.rawValue] as? UInt64
                                        return tempValueTimestamp
                                    }
                                }
                                
                                return datanode
                            }
                            completion(datanodeReadArray, nil)
                        }
                    }
                } else {
                    completion(nil, getErrorInfo(object: object))
                }
            }
        }
        
    }
    
    /**
     Gets an array of datanodes and their values from a device.
     
     - parameters:
     
        - deviceId: The id of the device from where to read the device data nodes. It consists of 32 alphanumeric characters.
        - limit: The limit of devices to output.
        - offset: Number of devices to skip.
        - completion: A closure which is called with datanodesList (DatanodeList object) and error (IoTServerError) if any.
     */
    
    open func getDatanodes(deviceId: String, limit: Int = 10, offset: Int = 0, completion: @escaping DownloadedDeviceDatanodes) {
        /// URL path for getting datanodes
        var param: String { return deviceResource + "\(deviceId)/datanodes?limit=\(limit)&offset=\(offset)" }
        get(request: clientURLRequest(path: param, credentials: credentials)) { (success, object) -> () in
            
            DispatchQueue.main.async() { () -> Void in
                if success {
                    if let json = object as? Dictionary<String, AnyObject> {
                        var datanodeList = DatanodeList()
                        if let items = json["items"] as? Array<Dictionary<String, AnyObject>> {
                            var datanode = DatanodeInfo()
                            datanodeList.datanodes = items.map { item -> DatanodeInfo in
                                datanode.dataType = item["dataType"] as? String
                                datanode.href = item["href"] as? String
                                datanode.name = item["name"] as? String
                                datanode.path = item["path"] as? String
                                datanode.unit = item["unit"] as? String
                                return datanode
                            }
                        }
                        datanodeList.fullSize = json["fullSize"] as? Int
                        datanodeList.limit = json["limit"] as? Int
                        datanodeList.offset = json["offset"] as? Int
                        completion(datanodeList, nil)
                    }
                } else {
                    completion(nil, getErrorInfo(object: object))
                }
            }
            
        }
    }
    
    /**
     Gets the information of devices.
     
     - parameters:
     
        - limit: The limit of devices to output.
        - offset: Number of devices to skip.
        - completion: A closure which is called with deviceDetaisArray (array of DeviceDetails object) and error (IoTServerError) if any.
     */
    
    open func getDevices(limit: Int = 10, offset: Int = 0, completion: @escaping DownloadedDeviceDetailsArray) {
        /// URL path for getting information of devices
        var param: String { return deviceResource + "?limit=\(limit)&offset=\(offset)" }
        get(request: clientURLRequest(path: param, credentials: credentials)) { (success, object) -> () in
            print(object!)
            DispatchQueue.main.async() { () -> Void in
                if success {
                    if let json = object as? Dictionary<String, AnyObject> {
                        var devicesList = DevicesList()
                        if let items = json["items"] as? Array<Dictionary<String, AnyObject>> {
                            devicesList.devices = items.map { item -> Device in
                                let deviceDetails = Device()
                                deviceDetails.name = item["name"] as! String!
                                deviceDetails.manufacturer = item["manufacturer"] as! String!
                                deviceDetails.deviceId = item["deviceId"] as? String
                                deviceDetails.createdAt = item["createdAt"] as? String
                                deviceDetails.href = URL(string: item["href"] as! String)
                                deviceDetails.attributes = item["attributes"] as? [Dictionary<String, String>]
                                deviceDetails.deviceDescription = item["description"] as? String
                                deviceDetails.type = item["type"] as? String
                                return deviceDetails
                            }
                        }
                        devicesList.fullSize = json["fullSize"] as? Int
                        devicesList.limit = json["limit"] as? Int
                        devicesList.offset = json["offset"] as? Int
                        completion(devicesList, nil)
                    }
                } else {
                    completion(nil, getErrorInfo(object: object))
                }
            }
            
        }
    }
    
    /**
     Gets the information of a device.
     
     - parameters:
     
        - deviceId: The id of the device, to be used in subsequent calls to write and read the device data nodes. It consists of 32 alphanumeric characters.
        - completion: A closure which is called with deviceDetais (DeviceDetails object) and error (IoTServerError) if any.
     */
    
    open func getDevice(deviceId: String, completion: @escaping DownloadedDeviceDetails) {
        /// URL path for getting the infomation of a device
        var specificDeviceResourceFormat: String { return deviceResource + "\(deviceId)/" }
        get(request: clientURLRequest(path: specificDeviceResourceFormat, credentials: credentials)) { (success, object) -> () in
            
            DispatchQueue.main.async() { () -> Void in
                if success {
                    if let json = object as? Dictionary<String, AnyObject> {
                        let deviceDetails = Device()
                        deviceDetails.deviceId = json["deviceId"] as? String
                        deviceDetails.createdAt = json["createdAt"] as? String
                        deviceDetails.href = URL(string: json["href"] as! String)
                        deviceDetails.attributes = json["attributes"] as? [Dictionary<String, String>]
                        deviceDetails.type = json["type"] as? String
                        deviceDetails.manufacturer = json["manufacturer"] as? String
                        deviceDetails.deviceDescription = json["description"] as? String
                        deviceDetails.name = json["name"] as? String
                        completion(deviceDetails, nil)
                    }
                } else {
                    completion(nil, getErrorInfo(object: object))
                }
            }
        }
    }
    
    /**
     Register a device by providing needed parameters.
     
     - parameters:
     
        - device: The Device object to register
        - completion: A closure which is called with deviceDetais (DeviceDetails object) and error (IoTServerError) if any.
     */
    
    open func registerDevice(device: Device, completion: @escaping DownloadedDeviceDetails) {
        
        post(request: clientURLRequest(path: deviceResource, params: device.toDict(), credentials: credentials)) { (success, object) -> () in
            DispatchQueue.main.async() { () -> Void in
                if success {
                    if let json = object as? Dictionary<String, AnyObject> {
                        let deviceDetails = Device()
                        deviceDetails.name = json["name"] as! String!
                        deviceDetails.manufacturer = json["manufacturer"] as! String!
                        deviceDetails.type = json["type"] as? String
                        deviceDetails.deviceDescription = json["description"] as? String
                        deviceDetails.attributes = json["attributes"] as? [Dictionary<String, String>]
                        deviceDetails.deviceId = json["deviceId"] as? String
                        deviceDetails.createdAt = json["createdAt"] as? String
                        deviceDetails.href = URL(string: json["href"] as! String)
                        completion(deviceDetails, nil)
                    }
                } else {
                    completion(nil, getErrorInfo(object: object))
                }
            }
        }
        
    }
    
    /**
     Gets overall quota.
     
     - parameter completion: A closure which is called with quota (Quota object) and error (IoTServerError) if any.
     */
    
    open func getAllQuota(completion: @escaping DownloadedAllQuota) {
        /// URL path for overall quota
        var quotaAllResource: String { return "quota/all/" }
        get(request: clientURLRequest(path: quotaAllResource, credentials: credentials)) { (success, object) -> () in
            
            DispatchQueue.main.async() { () -> Void in
                if success {
                    if let json = object as? Dictionary<String, AnyObject> {
                        var quota = Quota()
                        quota.totalDevices = json["totalDevices"] as? Int
                        quota.maxNumberOfDevices = json["maxNumberOfDevices"] as? Int
                        quota.maxDataNodePerDevice = json["maxDataNodePerDevice"] as? Int
                        quota.usedStorageSize = json["usedStorageSize"] as? Int
                        quota.maxStorageSize = json["maxStorageSize"] as? Int
                        completion(quota, nil)
                    }
                } else {
                    completion(nil, getErrorInfo(object: object))
                }
            }
        }
    }
    
    /**
     Gets device specific quota.
     
     - parameters:
     
        - deviceId: The id of the device, to be used in subsequent calls to write and read the device data nodes. It consists of 32 alphanumeric characters.
        - completion: A closure which is called with deviceQuota (deviceQuota object) and error (IoTServerError) if any.
     */
    open func getDeviceQuota(deviceId: String, completion: @escaping DownloadedDeviceQuota) {
        /// URL path for device quota
        var quotaDeviceResource: String { return "quota/\(deviceId)/" }
        get(request: clientURLRequest(path: quotaDeviceResource, credentials: credentials)) { (success, object) -> () in
            
            DispatchQueue.main.async() { () -> Void in
                if success {
                    if let json = object as? Dictionary<String, AnyObject> {
                        var deviceQuota = DeviceQuota()
                        deviceQuota.deviceId = json["deviceId"] as? String
                        deviceQuota.totalRequestToday = json["totalRequestToday"] as? Int
                        deviceQuota.maxReadRequestPerDay = json["maxReadRequestPerDay"] as? Int
                        deviceQuota.numberOfDataNodes = json["numberOfDataNodes"] as? Int
                        deviceQuota.storageSize = json["storageSize"] as? Int
                        completion(deviceQuota, nil)
                    }
                } else {
                    completion(nil, getErrorInfo(object: object))
                }
            }
        }
    }
    
    //MARK: - REST Client
    
    /// Datatask to get the results of the request
    fileprivate func dataTask(request: URLRequest, method: String, completion: @escaping DownloadedData) {
        var mutableRequest = request
        mutableRequest.httpMethod = method
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: mutableRequest) { (data, response, error) -> Void in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    completion(true, json)
                } else {
                    completion(false, json)
                }
            }
            }.resume()
        
    }
    /// Post request
    fileprivate func post(request: URLRequest, completion: @escaping DownloadedData) {
        dataTask(request: request, method: "POST", completion: completion)
    }
    /// Get request
    fileprivate func get(request: URLRequest, completion: @escaping DownloadedData) {
        dataTask(request: request, method: "GET", completion: completion)
    }
    
    /**
     Setup URL request with parameters and credentials.
     
     - parameters:
     
        - path: URL path for the request.
        - params: parameters to include in the HTTP body.
        - credentials: basic credentials to include in the request
     */
    fileprivate func clientURLRequest(path: String, params: Any? = nil, credentials: String?) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        print("PATH: ", baseURL + path)
        if let params = params {
            let jsonData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            print("PARAMS: \(params)")
            print("HTTP BODY: ", String(bytes: request.httpBody!, encoding: String.Encoding.utf8)!)
        }
        if let credentials = credentials {
            request.addValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}


// MARK: - Additional methods

/// Convert date time to timestamp in the format "yyyy-MM-dd HH:mm:ss".
public func dateToTimestamp(date: String) -> UInt64? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let realDate = dateFormatter.date(from: date)
    guard let notNilDate = realDate else {
        return nil
    }
    let intervalSince1970 = UInt64(notNilDate.timeIntervalSince1970*1000)
    return intervalSince1970
}

/// Function to make a device attribute.
public func deviceAttribute(key: String, value: String) -> Dictionary<String,String> {
    var mutableKey = key
    var mutableValue = value
    return ["key":mutableKey.restrictString(restriction: IoTRestrictions.maxAttributeLength), "value":mutableValue.restrictString(restriction: IoTRestrictions.maxAttributeLength)]
}

///Extract error from server.
fileprivate func getErrorInfo(object: Any?) -> IoTServerError? {
    var message = "There was an error"
    var Code: Int? = nil
    if let error = object as? Dictionary<String, AnyObject> {
        if let errorCode = error["code"] as? Int, let description = error["description"] as? String {
            message += ": \(description)\n Code: \(errorCode)"
            Code = errorCode
            print(message)
            return IoTServerError(rawValue: Code!)
        }
    }
    
    return IoTServerError.UncaughtException
}
