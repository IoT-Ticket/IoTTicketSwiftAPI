//
//  IoTTicketSwiftAPISpec.swift
//  IoTTicketSwiftAPI
//
//  Created by Daniel Egerev on 4/18/17.
//  Copyright © 2017 IoTTicket-swift. All rights reserved.
//

import XCTest
@testable import IoTTicketSwiftAPI

class IoTTicketSwiftAPITests: XCTestCase {
    
    
    var username: String!
    var password: String!
    var baseURL: String!
    var deviceId: String!
    var client: IoTTicketClient!
    
    override func setUp() {
        super.setUp()
        
        username = "***REMOVED***"
        password = "***REMOVED***"
        baseURL = "https://my.iot-ticket.com/api/v1"
        deviceId = "4e0f17895ae04c57a6d24baaae08b6b3"
        client = IoTTicketClient(baseURL: baseURL, username: username, password: password)
        
    }
    
    func testGetDevice() {
        
        let expect = expectation(description: "The function should get device information for specific deviceId")
        
        client.getDevice(deviceId: deviceId) { deviceDetails, error in
            
            XCTAssertNotNil(deviceDetails?.createdAt)
            XCTAssertNotNil(deviceDetails?.name)
            XCTAssertEqual(self.deviceId, deviceDetails?.deviceId)
            XCTAssertNotNil(deviceDetails?.manufacturer)
            XCTAssertNotNil(deviceDetails?.href)
            expect.fulfill()
        }
        
        waitExpectation()
    }
    
    func testRegisterDevice() {
        let expect = expectation(description: "The function should register a device and return deviceDetails")
        let device = Device(name: "Swift", manufacturer: "Apple", type: "Wapice", deviceDescription: "Testing Swift API", attributes: [deviceAttribute(key: "swift", value: "api"), deviceAttribute(key: "create", value: "apps")])
        
        client.registerDevice(device: device) { deviceDetails, error in
            
            XCTAssertNotNil(deviceDetails?.name)
            XCTAssertNotNil(deviceDetails?.createdAt)
            XCTAssertNotNil(deviceDetails?.deviceDescription)
            XCTAssertNotNil(deviceDetails?.deviceId)
            XCTAssertNotNil(deviceDetails?.href)
            XCTAssertNotNil(deviceDetails?.type)
            XCTAssertNotNil(deviceDetails?.manufacturer)
            XCTAssertEqual(2, deviceDetails?.attributes?.count)
            expect.fulfill()
        }
        
        waitExpectation()
    }
    
    func testGetDevices() {
        
        let expect = expectation(description: "The function should get all devices and their details")
        
        client.getDevices { devicesList, error in
            
            XCTAssertTrue((devicesList?.fullSize)!>=1)
            XCTAssertEqual(10, devicesList?.limit)
            XCTAssertEqual(0, devicesList?.offset)
            XCTAssertNotNil(devicesList?.devices)
            expect.fulfill()
        }
        
        waitExpectation()
    }
    
    func testGetAllQuota() {
        
        let expect = expectation(description: "The function should get overall quota")
        
        client.getAllQuota { quota, error in
            
            XCTAssertNotNil(quota?.maxDataNodePerDevice)
            XCTAssertNotNil(quota?.maxNumberOfDevices)
            XCTAssertNotNil(quota?.maxStorageSize)
            XCTAssertNotNil(quota?.totalDevices)
            XCTAssertNotNil(quota?.usedStorageSize)
            expect.fulfill()
        }
        
        waitExpectation()
    }
    
    func testGetDeviceQuota() {
        
        let expect = expectation(description: "The function should get device specific quota")
        
        client.getDeviceQuota(deviceId: deviceId) { deviceQuota, error in
            
            XCTAssertNotNil(deviceQuota?.maxReadRequestPerDay)
            XCTAssertNotNil(deviceQuota?.numberOfDataNodes)
            XCTAssertNotNil(deviceQuota?.storageSize)
            XCTAssertNotNil(deviceQuota?.totalRequestToday)
            XCTAssertEqual(self.deviceId, deviceQuota?.deviceId)
            expect.fulfill()
        }
        
        waitExpectation()
    }
    
    func testWriteDatanodes() {
        
        let expect = expectation(description: "The function should write datanode to server")
        
        let datanode = Datanode(name: "latitude", v: arc4random())
        let datanode2 = Datanode(name: "Swift API Datanode", path: "/Swift", v: arc4random(), dataType: DataType.long.rawValue)
        
        client.writeDatanode(deviceId: deviceId, datanodes: [datanode, datanode2]) { writeDatanodesResult, error in
            
            XCTAssertEqual(2, writeDatanodesResult?.writeResults?.count)
            XCTAssertEqual(2, writeDatanodesResult?.totalWritten)
            expect.fulfill()
        }
        
        waitExpectation()
    }
    
    func testReadDatanodes() {
        
        let expect = expectation(description: "The function should read datanodes value")
        
        let fromDate = dateToTimestamp(date: "2016-02-21 00:00:00")
        let toDate = dateToTimestamp(date: "2018-04-11 00:00:00")
        
        client.readDatanodes(deviceId: deviceId, criteria: ["latitude", "Swift API Datanode"], fromDate: fromDate, toDate: toDate, limit: 10000) { datanodeReadArray, error in
            XCTAssertNotNil(datanodeReadArray?.datanodeReads)
            expect.fulfill()
        }
        
        waitExpectation()
    }
    
    
    func testGetDatanodes() {
        
        let expect = expectation(description: "The function should get all datanodes from device")
        
        client.getDatanodes(deviceId: deviceId, limit: 10, offset: 0){ deviceDatanodes, error in
            
            XCTAssertTrue((deviceDatanodes?.fullSize)!>=2)
            XCTAssertEqual(10, deviceDatanodes?.limit)
            XCTAssertEqual(0, deviceDatanodes?.offset)
            print(deviceDatanodes?.datanodes as Any)
            expect.fulfill()
        }
        
        waitExpectation()
    }
    
    
    private func waitExpectation() {
        
        waitForExpectations(timeout: 100) { error in
            if let error = error {
                XCTFail("WaitForExpectation timed out with error: \(error)")
            }
        }
    }

}
