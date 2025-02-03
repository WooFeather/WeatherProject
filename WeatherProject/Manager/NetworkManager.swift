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
    
    func callOpenWeatherAPI<T: Decodable>(api: OpenWeatherRequest,
                                   type: T.Type,
                                   completionHandler: @escaping (T) -> Void,
                                   failHandler: @escaping () -> Void)
    {
        AF.request(api.endpoint, method: api.method)
            .responseDecodable(of: T.self) { response in
                print(api.endpoint)
                switch response.result {
                case .success(let value):
                    print("✅ SUCCESS")
                    completionHandler(value)
                case .failure(let error):
                    print("❌ FAIL \(error)")
                    failHandler()
                }
            }
    }
}
