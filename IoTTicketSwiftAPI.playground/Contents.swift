//: Playground - noun: a place where people can play

import IoTTicketSwiftAPI

var str = "Hello, playground"

let username = "username"
let password = "password"
let baseURL = "https://my.iot-ticket.com/api/v1"
let deviceId = "deviceId"
let client = IoTTicketClient(baseURL: baseURL, username: username, password: password)
