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
//    private var mapView: NMFMapView?
    let locationManager = CLLocationManager()
    let viewModel = LocationViewModel()
    
    private var didInitialized = false // 초기화 여부
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindingData()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 거리 정확도 설정 (설정하지 않을 시 kcLLocationAccuracyBest가 디폴트)
        
        checkAuthorizationStatus()
        setLayout()
    }
    
    private func bindingData() {
        viewModel.stateChanged = { [weak self] state in
            guard let self else { return }
            
            switch state {
            case let .initialized(lat, lng, data): // 초기 설정
                setMapView(lat: lat, lng: lng)
//                setMarkers(of: markers)
                
                Task {
                    let markers = await self.makeMarkers(data)
                    self.displayMarkers(markers)
                }
                
            case let .locationChanged(lat, lng): // 위치 이동 시
                moveCameraPosition(lat: lat, lng: lng)
                
//            case let .fetchMarkers(arr):
//                setMarkers(of: arr)
                
            case .none:
                break
            }
        }
    }
}

//MARK: Set MapView
extension MapViewController {
    private func setMapView(lat: Double, lng: Double) {
        mapView.mapType = .basic // 지도 유형 설정
        mapView.isNightModeEnabled = UITraitCollection.current.userInterfaceStyle == .dark // 다크모드 설정
        mapView.allowsTilting = false // 기울임 설정
        
        moveCameraPosition(lat: lat, lng: lng) // 카메라 포지션 변경 - 현재 위치를 비추도록
        
        // 현 위치 표시
        let locationOverlay = mapView.locationOverlay
        locationOverlay.hidden = false
        mapView.positionMode = .direction
    }
    
    private func setLayout() {
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    //MARK: 마커의 생성과 배치
    /*
     네이버 지도의 오버레이 객체는 아무 스레드에서 생성할 수 있으나 오버레이의 속성은 스레드 안전성이 보장되지 않으므로 여러 스레드에서 동시에 접근해서는 안됩니다.
     특히, 지도에 추가된 오버레이의 속성은 메인 스레드에서만 접근해야합니다. (그렇지 않으면 크래시 발생)
     
     대량의 오버레이를 다룰 경우 객체를 생성하고 초기 옵션을 지정하는 작업은 백그라운드 스레드에서 수행하고,
     지도에 추가하는 작업만 메인스레드에서 수행하면 메인스레드를 효율적으로 사용 가능합니다.
     
     현재 프로젝트에서는 대량의 오버레이 객체를 다루지는 않지만 async await의 적용을 위해 두 작업을 나누어보았습니다.
     */
    
    // 마커 생성
    @globalActor actor BackgroundActor: GlobalActor {
        static let shared = BackgroundActor()
    }
    
    @BackgroundActor
    private func makeMarkers(_ markers: [(type: String, lat: Double, lng: Double)]) async -> [NMFMarker] {
        return markers.reduce(into: [NMFMarker]()) {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: $1.lat, lng: $1.lng)
            
            switch $1.type {
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
                return true // 이벤트를 지도로 전달하지 않음 (마커에서 이벤트를 소비)
            }
            
            $0.append(marker)
        }
    }
    
    // 마커 배치
    @MainActor
    private func displayMarkers(_ markers: [NMFMarker]) {
        markers.forEach {
            $0.mapView = mapView
        }
    }
    
    private func deleteMarker() {
        
    }
    
}


extension MapViewController {
    private func moveCameraPosition(lat: Double, lng: Double) {
        let cameraPosition = NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(lat: lat, lng: lng), zoom: 14))
        mapView.moveCamera(cameraPosition)
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
        if didInitialized { // 맵뷰 초기 설정 이후일 경우
            viewModel.action(.didUpdateLocations(lat: lat, lng: lng))
        } else { // 맵뷰 초기 설정 이전일 경우
            viewModel.action(.initialized(lat: lat, lng: lng))
            didInitialized = true // 초기화 여부 변경
        }
        

        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
