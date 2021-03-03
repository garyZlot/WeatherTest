//
//  ForecastViewModel.swift
//  WeatherTest
//
//  Created by liuguangde on 2021/2/27.
//

import Foundation

struct ForecastViewModel {
    let day: Observable<String>
    let time: Observable<String>
    let iconText: Observable<String>
    let temperature: Observable<String>
    
    init(_ forecast: Forecast) {
        day = Observable(forecast.day)
        time = Observable(forecast.time)
        iconText = Observable(forecast.iconText)
        temperature = Observable(forecast.temperature)
    }
}
