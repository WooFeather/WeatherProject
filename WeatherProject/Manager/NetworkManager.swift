//
//  NetworkManager.swift
//  WeatherProject
//
//  Created by 조우현 on 2/3/25.
//

import UIKit
import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() { }
    
    func callOpenWeatherAPI(api: OpenWeatherRequest, completionHandler: @escaping (Result<Weather,AFError>) -> Void) {
        AF.request(api.endpoint, method: api.method)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: Weather.self) { response in
                print(api.endpoint)
                switch response.result {
                case .success(let value):
                    print("✅ SUCCESS")
                    completionHandler(.success(value))
                case .failure(let error):
                    print("❌ FAIL \(error)")
                    completionHandler(.failure(error))
                }
            }
    }
}
