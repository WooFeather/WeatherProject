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
    
    // MARK: - Location Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        checkSystemLocation()
    }
    
    private func checkSystemLocation() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.checkAuthorizationStatus()
            } else {
                print("❌SYSTEM DENIED")
                self.setDefaultRegionAndAnnotation()
                
                DispatchQueue.main.async {
                    self.showAlert(title: "위치서비스 사용 불가", message: "위치 서비스를 사용할 수 없습니다.\n기기의 '설정->개인정보 보호'에서 위치 서비스를 켜주세요.", button: "설정으로 이동", isCancelButton: true) {
                        // 설정앱으로 이동
                        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                            UIApplication.shared.open(appSettings)
                        }
                    }
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            print("❌DENIED")
            setDefaultRegionAndAnnotation()
            
            DispatchQueue.main.async {
                self.showAlert(title: "위치서비스 사용 불가", message: "위치 서비스를 사용할 수 없습니다.\n기기의 '설정->개인정보 보호'에서 위치 서비스를 켜주세요.", button: "설정으로 이동", isCancelButton: true) {
                    // 설정앱으로 이동
                    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
        case .authorizedWhenInUse:
            print("✅AUTHORIZED")
            locationManager.startUpdatingLocation()
        default:
            print("권한 확인 실패")
        }
    }
    
    private func setRegionAndAnnotation(center: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 500, longitudinalMeters: 500)
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        
        mapView.setRegion(region, animated: true)
        
        // 이전의 annotations 삭제
        mapView.removeAnnotations(mapView.annotations)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    private func setDefaultRegionAndAnnotation() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.65425433473966, longitude: 127.04988768252423)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        mapView.setRegion(region, animated: true)
        
        DispatchQueue.main.async {
            // 이전의 annotations 삭제
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.showAnnotations([annotation], animated: true)
        }
    }
    
    // MARK: - Actions
    @objc private func currentLocationButtonTapped() {
        checkSystemLocation()
    }
    
    @objc private func refreshButtonTapped() {
        // TODO: 날씨 새로고침 구현 (API 재호출)
    }
}

// MARK: - Extension
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function)
        // TODO: OpenWeatherAPI 호출
        
        if let coordinate = locations.last?.coordinate {
            setRegionAndAnnotation(center: coordinate)
        } else {
            setDefaultRegionAndAnnotation()
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(#function)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        checkSystemLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function)
        checkSystemLocation()
    }
}
