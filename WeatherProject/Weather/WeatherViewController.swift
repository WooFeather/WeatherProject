//
//  WeatherViewController.swift
//  SeSACSevenWeek
//
//  Created by Jack on 2/3/25.
//

// DispatchQueue.main.async { } 코드가 많은 이유는 Thread관련 오류가 계속 떠서 일단 UI그리는 코드엔 다 붙여놨는데, 시뮬레이터로 테스틀했을때만 발생하는듯합니다.

import UIKit
import CoreLocation
import MapKit
import SnapKit

import Alamofire

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
    
//    private var temp: Double?
//    private var minTemp: Double?
//    private var maxTemp: Double?
//    private var humidity: Double?
//    private var windSpeed: Double?
    
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
    
    
//    private func setupWeatherInfoLabel() {
//        weatherInfoLabel.text =
//        """
//        \(Date().toString())
//        현재온도: \(temp ?? 0.0)°C
//        최저온도: \(minTemp ?? 0.0)°C
//        최고온도: \(maxTemp ?? 0.0)°C
//        풍속: \(windSpeed ?? 0.0)m/s
//        습도: \(humidity ?? 0.0)%
//        """
//    }
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
                self.callRequest(latitude: 37.65425433473966, longitude: 127.04988768252423)
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
            self.callRequest(latitude: 37.65425433473966, longitude: 127.04988768252423)
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
        
        DispatchQueue.main.async {
            // 이전의 annotations 삭제
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.showAnnotations([annotation], animated: true)
        }
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
    
    // MARK: - Networking Setup
    private func callRequest(latitude: Double, longitude: Double) {
        NetworkManager.shared.callOpenWeatherAPI(api: .currentWeather(latitude: latitude, longitude: longitude)) { response in
            switch response {
            case .success(let success):
//                self.temp = success.main.temp
//                self.minTemp = success.main.minTemp
//                self.maxTemp = success.main.maxTemp
//                self.humidity = success.main.humidity
//                self.windSpeed = success.wind.speed
                
                DispatchQueue.main.async {
                    self.weatherInfoLabel.text =
                    """
                    \(Date().toString())
                    현재온도: \(success.main.temp)°C
                    최저온도: \(success.main.minTemp)°C
                    최고온도: \(success.main.maxTemp)°C
                    풍속: \(success.wind.speed)m/s
                    습도: \(success.main.humidity)%
                    """
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.showAlert(title: "네트워크 오류", message: "네트워크 오류로 날씨정보를 가져올 수 없습니다.", button: "닫기") {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func currentLocationButtonTapped() {
        checkSystemLocation()
    }
    
    @objc private func refreshButtonTapped() {
        // 이렇게 날씨정보만 다시 조회해도 될까요?
        DispatchQueue.main.async {
            self.weatherInfoLabel.text = "날씨 정보를 불러오는 중..."
        }
        let coordinate = locationManager.location?.coordinate
        callRequest(latitude: coordinate?.latitude ?? 0.0, longitude: coordinate?.longitude ?? 0.0)
        
        // 혹은, 권한이 바뀌었을때 분기처리를 대비해서 다시 checkSystemLocation()를 호출하는게 나을까요?
        // 근데 이렇게 하면 현재위치 버튼과 같은 동작이어서 위의 동작으로 구현했습니다!
        // checkSystemLocation()
    }
}

// MARK: - Extension
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function)
        
        if let coordinate = locations.last?.coordinate {
            setRegionAndAnnotation(center: coordinate)
            callRequest(latitude: coordinate.latitude, longitude: coordinate.longitude)
//            DispatchQueue.main.async {
//                self.setupWeatherInfoLabel()
//            }
        } else {
            setDefaultRegionAndAnnotation()
            callRequest(latitude: 37.65425433473966, longitude: 127.04988768252423)
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
