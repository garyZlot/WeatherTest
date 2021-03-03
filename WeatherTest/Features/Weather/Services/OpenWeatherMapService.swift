//
//  OpenWeatherMapService.swift
//  WeatherTest
//
//  Created by liuguangde on 2021/2/28.
//

import Foundation
import CoreLocation
import SwiftyJSON

struct OpenWeatherMapService: WeatherServiceProtocol {
    private let urlPath = "http://api.openweathermap.org/data/2.5/forecast"
    
    private func getForecasts(_ json: JSON) -> [Forecast] {
        var forecasts: [Forecast] = []
        
        for index in 0...(json["list"].count - 1) {
            guard let forecastTempDegrees = json["list"][index]["main"]["temp"].double,
                let rawDateTime = json["list"][index]["dt"].double,
                let forecastCondition = json["list"][index]["weather"][0]["id"].int,
                let forecastIcon = json["list"][index]["weather"][0]["icon"].string else {
                    break
            }
            
            let country = json["city"]["country"].string
            let forecastTemperature = Temperature(country: country!,
                                                  openWeatherMapDegrees: forecastTempDegrees)
            let forecastDayTimeString = ForecastDateTime(date: rawDateTime, timeZone: TimeZone.current).dayTime
            let forecastTimeString = ForecastDateTime(date: rawDateTime, timeZone: TimeZone.current).shortTime
            let weatherIcon = WeatherIcon(condition: forecastCondition, iconString: forecastIcon)
            let forcastIconText = weatherIcon.iconText
            
            let forecast = Forecast(day: forecastDayTimeString,
                                    time: forecastTimeString,
                                    iconText: forcastIconText,
                                    temperature: forecastTemperature.degrees)
            
            forecasts.append(forecast)
        }
        
        return forecasts
    }
    
    func retrieveWeatherInfo(_ location: CLLocation, completionHandler: @escaping WeatherCompletionHandler) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        guard let url = generateRequestURL(location) else {
            let error =  SWError(errorCode: .urlError)
            completionHandler(nil, error)
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            // Check network error
            guard error == nil else {
                let error = SWError(errorCode: .networkRequestFailed)
                completionHandler(nil, error)
                return
            }
            
            // Check JSON serialization error
            guard let data = data else {
                let error = SWError(errorCode: .jsonSerializationFailed)
                completionHandler(nil, error)
                return
            }
            
            guard let json = try? JSON(data: data) else {
                let error = SWError(errorCode: .jsonParsingFailed)
                completionHandler(nil, error)
                return
            }
            
            guard let tempDegress = json["list"][0]["main"]["temp"].double,
                  let country = json["city"]["country"].string,
                  let city = json["city"]["name"].string,
                  let weatherCondition = json["list"][0]["weather"][0]["id"].int,
                  let iconString = json["list"][0]["weather"][0]["icon"].string else {
                      let error = SWError(errorCode: .jsonParsingFailed)
                      completionHandler(nil, error)
                      return
            }
            
            var weatherBuilder = WeatherBuilder()
            let temperature = Temperature(country: country, openWeatherMapDegrees: tempDegress)
            weatherBuilder.temperature = temperature.degrees
            weatherBuilder.location = city
            
            let weatherIcon = WeatherIcon(condition: weatherCondition, iconString: iconString)
            weatherBuilder.iconText = weatherIcon.iconText
            
            weatherBuilder.forecasts = self.getForecasts(json)
            
            completionHandler(weatherBuilder.build(), nil)
        }
        
        task.resume()
    }
    
    
    private func generateRequestURL(_ location: CLLocation) -> URL? {
        guard var components = URLComponents(string: urlPath) else {
            return nil
        }
        
        let filePath = Bundle.main.path(forResource: "Info", ofType: "plist")!
        let parameters = NSDictionary(contentsOfFile: filePath)
        let appId = parameters!["OWMAccessToken"]! as! String
        
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        
//        components.queryItems = [URLQueryItem(name: "lat", value: latitude),
//                                URLQueryItem(name: "lon", value: longitude),
//                                URLQueryItem(name: "appid", value: appId)]
        
        components.queryItems = [URLQueryItem(name: "q", value: "Weifang"),
                                URLQueryItem(name: "appid", value: appId)]
        
        return components.url
    }
    
}
