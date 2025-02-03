//
//  Weather.swift
//  WeatherProject
//
//  Created by 조우현 on 2/3/25.
//

import Foundation

struct Weather: Decodable {
    let main: MainInfo
    let wind: WindInfo
}

struct MainInfo: Decodable {
    let temp: Double
    let minTemp: Double
    let maxTemp: Double
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case minTemp = "temp_min"
        case maxTemp = "temp_max"
        case humidity
    }
}

struct WindInfo:Decodable {
    let speed: Double
}
