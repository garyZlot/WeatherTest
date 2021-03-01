//
//  Weather.swift
//  WeatherTest
//
//  Created by liuguangde on 2021/2/27.
//

import Foundation

struct Weather {
    let location: String
    let iconText: String
    let temperature: String
    
    let forecasts: [Forecast]
}
