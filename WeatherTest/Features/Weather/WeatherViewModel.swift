//
//  WeatherViewModel.swift
//  WeatherTest
//
//  Created by liuguangde on 2021/2/27.
//

import Foundation
import CoreLocation

class WeatherViewModel {
    // MARK: - Constants
    private let emptyString = ""
    
    // MARK: - Properties
    let hasError: Observable<Bool>
    let errorMessage: Observable<String?>
    
    let location: Observable<String>
    let iconText: Observable<String>
    let temperature: Observable<String>
    let forecasts: Observable<[ForecastViewModel]>
    
    // MARK: - Services
    private var locationService: LocationService
    private var weatherService: WeatherServiceProtocol
    
    init() {
        hasError = Observable(false)
        errorMessage = Observable(nil)
        
        location = Observable(emptyString)
        iconText = Observable(emptyString)
        temperature = Observable(emptyString)
        forecasts = Observable([])
        
        locationService = LocationService()
        weatherService = OpenWeatherMapService()
    }
    
    // MARK: - public
    func startLocationService() {
        locationService.delegate = self
        locationService.requestLocation()
    }
    
    // MARK: - private
    private func update(_ weather: Weather) {
        hasError.value = false
        errorMessage.value = nil

        location.value = weather.location
        iconText.value = weather.iconText
        temperature.value = weather.temperature

        let tempForecasts = weather.forecasts.map { forecast in
          return ForecastViewModel(forecast)
        }
        forecasts.value = tempForecasts
    }
    
    private func update(_ error: SWError) {
        hasError.value = true

        switch error.errorCode {
            case .urlError:
              errorMessage.value = "The weather service is not working."
            case .networkRequestFailed:
              errorMessage.value = "The network appears to be down."
            case .jsonSerializationFailed:
              errorMessage.value = "We're having trouble processing weather data."
            case .jsonParsingFailed:
              errorMessage.value = "We're having trouble parsing weather data."
            case .unableToFindLocation:
              errorMessage.value = "We're having trouble getting user location."
        }
      
        location.value = emptyString
        iconText.value = emptyString
        temperature.value = emptyString
        self.forecasts.value = []
    }
}

// MARK: LocationServiceDelegate
extension WeatherViewModel: LocationServiceDelegate {
    func locationDidUpdate(_ service: LocationService, location: CLLocation) {
        weatherService.retrieveWeatherInfo(location) { (weather, error) -> Void in
            DispatchQueue.main.async {
                if let unwrappedError = error {
                    print(unwrappedError)
                    self.update(unwrappedError)
                    return
                }
                
                guard let unwrappedWeather = weather else {
                    return
                }
                
                self.update(unwrappedWeather)
            }
        }
    }
    
    func locationDidFail(withError error: SWError) {
        
    }
}
