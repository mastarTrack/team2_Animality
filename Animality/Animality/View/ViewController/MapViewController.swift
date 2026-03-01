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
    let viewModel = LocationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindingData()
        
        setMapView()
        setLayout()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 거리 정확도 설정 (설정하지 않을 시 kcLLocationAccuracyBest가 디폴트)
        checkAuthorizationStatus()
    }
    
    private func bindingData() {
        viewModel.stateChanged = { [weak self] state in
            guard let self else { return }
            
            switch state {                
            case let .locationChanged(lat, lng):
                let cameraUpdate = NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(lat: lat, lng: lng), zoom: 14))
                mapView.moveCamera(cameraUpdate)
            case let .fetchMarkers(arr):
                setMarkers(of: arr)
            case .none:
                break
            }
        }
    }
}

//MARK: Set MapView
extension MapViewController {
    private func setMapView() {
        mapView.mapType = .basic // 지도 유형 설정
        mapView.isNightModeEnabled = UITraitCollection.current.userInterfaceStyle == .dark // 다크모드 설정
        mapView.allowsTilting = false // 기울임 설정
        
        viewModel.action(.fetchMarkers)
    }
    
    private func setLayout() {
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
//    private func setCurrentLocation(lat: Double, lng: Double) {
//        let cameraUpdate = NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(lat: lat, lng: lng), zoom: 14))
//        mapView.moveCamera(cameraUpdate)
//        
//    }
    
    private func setMarkers(of points: [(type: String, lat: Double, lng: Double)]) {
        points.forEach {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: $0.lat, lng: $0.lng) // 좌표 지정
            marker.mapView = mapView // 맵뷰에 추가
            
            // 아이콘 이미지 설정
            switch $0.type {
            case "강아지":
                marker.iconImage = NMFOverlayImage(image: .dogPin)
            case "고양이":
                marker.iconImage = NMFOverlayImage(image: .catPin)
            case "페가수스":
                marker.iconImage = NMFOverlayImage(image: .pegasusPin)
            case "유니콘":
                marker.iconImage = NMFOverlayImage(image: .unicornPin)
            case "초코보":
                marker.iconImage = NMFOverlayImage(image: .chocoboPin)
            default:
                break
            }
            
            marker.width = 30 // 마커 사이즈
            marker.height = 44
            
            marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                print("lat: \(marker.position.lat), lng: \(marker.position.lng)")
                return true
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    // 위치 정보 권한 상태 확인
    private func checkAuthorizationStatus() {
        if locationManager.authorizationStatus == .authorizedAlways
            || locationManager.authorizationStatus == .authorizedWhenInUse { // 위치 권한 허용시(항상 || 앱을 사용하는 동안)
            locationManager.requestLocation() // 현재 위치 정보
        } else if locationManager.authorizationStatus == .notDetermined { // 위치 권한 미지정시
            locationManager.requestWhenInUseAuthorization() // 권한 요청
        } else if locationManager.authorizationStatus == .denied {
            print("위치 권한 거절 상태")
        }
    }
    
    // startUpdatingLocation, requestLocation이 호출되었을 때 호출되는 함수
    //  - startUpdatingLocation: 현재 위치를 실시간으로 업데이트 하는 함수
    //  - requestLocation: 현재 위치를 1회성으로 업데이트 하는 함수
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var lat: Double? // 현재 위도
        var lng: Double? // 현재 경도
        
        if let location = locations.first {
            lat = Double(location.coordinate.latitude)
            lng = Double(location.coordinate.longitude)
        }
        
        guard let lng, let lat else { return }
        viewModel.action(.didUpdateLocations(lat: lat, lng: lng))

        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
