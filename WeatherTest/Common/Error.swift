//
//  Error.swift
//  WeatherTest
//
//  Created by liuguangde on 2021/2/28.
//

import Foundation

struct SWError {
    enum Code: Int {
        case urlError                 = -6000
        case networkRequestFailed     = -6001
        case jsonSerializationFailed  = -6002
        case jsonParsingFailed        = -6003
        case unableToFindLocation     = -6004
    }
    
    let errorCode: Code
}
