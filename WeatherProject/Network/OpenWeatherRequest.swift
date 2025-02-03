//
//  OpenWeatherRequest.swift
//  WeatherProject
//
//  Created by 조우현 on 2/3/25.
//

import Foundation
import Alamofire

enum OpenWeatherRequest {
    case currentWeather(latitude: Double, longitude: Double)
    
    private var baseURL: String {
        return "https://api.openweathermap.org/data/2.5/"
    }
    
    var endpoint: URL {
        switch self {
        case .currentWeather(let latitude, let longitude):
            return URL(string: baseURL + "weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(APIKey.openWeatherAPIKey)")!
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
}
