//
//  Criteria.swift
//  IoTTicketSwiftAPI
//
//  Created by Daniel Egerev on 4/18/17.
//  Copyright © 2017 IoTTicket-swift. All rights reserved.
//

import Foundation

/// Restrictions from API
struct IoTRestrictions {
    static let maxNameLength = 100
    static let maxDescriptionLength = 255
    static let maxAttributeLength = 255
    static let maxNumberOfAttributes = 50
    static let maxPathLength = 1000
    static let maxUnitLength = 10
    static let maxPathDepth = 10
    static let deviceIdLength = 32
}

/// Error codes form server API
public enum IoTServerError: Int {
    case InternalServerError = 8000
    case PermissionNotSufficient = 8001
    case QuotaViolation = 8002
    case BadInputParamter = 8003
    case CaseWriteFailed = 8004
    case UncaughtException
}
