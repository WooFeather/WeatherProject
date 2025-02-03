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
    let temp_min: Double
    let temp_max: Double
    let humidity: Double
}

struct WindInfo:Decodable {
    let speed: Double
}
