//
//  MapViewController.swift
//  Animality
//
//  Created by t2025-m0143 on 2/27/26.
//
import UIKit
import SnapKit
import NMapsMap
import CoreLocation

class MapViewController: UIViewController {
    let mapView = NMFMapView(frame: .zero)
    let locationManager = CLLocationManager()
    
    var currentLng: Double? // 현재 경도
    var currentLat: Double? // 현재 위도
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapView()
        setLayout()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 거리 정확도 설정 (설정하지 않을 시 kcLLocationAccuracyBest가 디폴트)
        checkAuthorizationStatus()
    }
}

//MARK: Set MapView
extension MapViewController {
    private func setMapView() {
        mapView.mapType = .basic // 지도 유형 설정
        mapView.isNightModeEnabled = UITraitCollection.current.userInterfaceStyle == .dark // 다크모드 설정
        mapView.allowsTilting = false // 기울임 설정
    }
    
    private func setLayout() {
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
//    private func getCurrentLocation() -> NMGLatLng {
//        
//    }
}

extension MapViewController: CLLocationManagerDelegate {
    // 위치 정보 권한 상태 확인
    private func checkAuthorizationStatus() {
        if locationManager.authorizationStatus == .authorizedAlways
            || locationManager.authorizationStatus == .authorizedWhenInUse { // 위치 권한 허용시(항상 || 앱을 사용하는 동안)
            locationManager.startUpdatingLocation() // 위치 정보 받기 시작
        } else if locationManager.authorizationStatus == .notDetermined { // 위치 권한 미지정시
            locationManager.requestWhenInUseAuthorization() // 권한 요청
        } else if locationManager.authorizationStatus == .denied {
            print("위치 권한 거절 상태")
        }
    }
    // startUpdatingLocation이 호출되었을 때 호출되는 함수
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLng = Double(location.coordinate.longitude)
            currentLat = Double(location.coordinate.latitude)
        }
        print("위도: \(currentLat), 경도: \(currentLng)")
        locationManager.stopUpdatingLocation()
    }
}
