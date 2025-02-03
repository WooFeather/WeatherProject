//
//  WeatherViewController.swift
//  SeSACSevenWeek
//
//  Created by Jack on 2/3/25.
//

import UIKit
import CoreLocation
import MapKit
import SnapKit

final class WeatherViewController: UIViewController {
     
    private let mapView: MKMapView = {
        let view = MKMapView()
        return view
    }()
    
    private let locationManager = CLLocationManager()
    
    private let weatherInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.text = "날씨 정보를 불러오는 중..."
        return label
    }()
    
    private let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupLocationManager()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        [mapView, weatherInfoLabel, currentLocationButton, refreshButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.snp.height).multipliedBy(0.5)
        }
        
        weatherInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        currentLocationButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(50)
        }
        
        refreshButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(50)
        }
    }
    
    private func setupActions() {
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - LocationManager Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        
        checkSystemLocation()
    }
    
    private func checkSystemLocation() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.checkAuthorizationStatus()
            } else {
                DispatchQueue.main.async {
                    // 지도 중심을 도봉캠퍼스로 옮기고 사용자에게 알럿 띄우고 설정으로 이동하기
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .denied:
            // 지도 중심을 도봉캠퍼스로 옮기고 사용자에게 알럿 띄우고 설정으로 이동하기
        case .authorizedWhenInUse:
            // OpenWeatherAPI 호출
            // 현재 위치에 시스템 어노테이션 표시
        default:
            print("권한 확인 실패")
        }
    }
    
    // MARK: - Actions
    @objc private func currentLocationButtonTapped() {
        // 현재 위치 가져오기 구현
    }
    
    @objc private func refreshButtonTapped() {
        // 날씨 새로고침 구현 (API 재호출)
    }
}

// MARK: - Extension
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        <#code#>
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        <#code#>
    }
}
