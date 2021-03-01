//
//  WeatherServiceProtocol.swift
//  WeatherTest
//
//  Created by liuguangde on 2021/2/28.
//

import Foundation
import CoreLocation

typealias WeatherCompletionHandler = (Weather?, SWError?) -> Void

protocol WeatherServiceProtocol {
    func retrieveWeatherInfo(_ location: CLLocation, completionHandler: @escaping WeatherCompletionHandler)
}
