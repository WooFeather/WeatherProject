//
//  Date+.swift
//  WeatherProject
//
//  Created by 조우현 on 2/3/25.
//

import UIKit

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월 d일 a h시 m분"
        return dateFormatter.string(from: self)
    }
}
