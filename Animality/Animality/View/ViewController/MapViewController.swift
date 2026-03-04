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
    private let locationManager = CLLocationManager()
    private let viewModel = LocationViewModel()
    
    private let mapView = NMFMapView(frame: .zero)
    private let searchBar = UISearchBar()
    private let currentLocationButton = UIButton()
    
    private var didInitialized = false // 초기화 여부
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindingData()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 거리 정확도 설정 (설정하지 않을 시 kcLLocationAccuracyBest가 디폴트)
        
        setAttributes()
        setLayout()
    }
    
    private func bindingData() {
        viewModel.stateChanged = { [weak self] state in
            guard let self else { return }
            
            switch state {
            case let .initialized(lat, lng, data): // 초기 설정
                setMapView(lat: lat, lng: lng)
                
                // 비동기 함수(마커 생성 함수)를 처리하기 위한 Task
                Task {
                    let markers = await self.makeMarkers(data)
                    self.displayMarkers(markers)
                }
                
            case let .locationChanged(lat, lng): // 위치 이동 시
                moveCameraPosition(lat: lat, lng: lng)
                
            case .none:
                break
            }
        }
    }
}

//MARK: Set Layout & Attributes
extension MapViewController {
    private func setLayout() {
        view.addSubview(mapView)
        view.addSubview(searchBar)
        view.addSubview(currentLocationButton)
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.bottom.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.width.height.equalTo(56)
        }
    }
    
    private func setAttributes() {
        setSearchBar()
        setButton()
        currentLocation()
    }
    
    private func setButton() {
        // configuration
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .coralText
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        
        currentLocationButton.configuration = config
        
        currentLocationButton.configurationUpdateHandler = { button in
            let imageConfig = UIImage.SymbolConfiguration(weight: .bold)
            
            button.configuration?.image =
            button.isHighlighted ? UIImage(systemName: "location.fill")
            : UIImage(systemName: "location", withConfiguration: imageConfig)
        }
        
        // action
        let move = UIAction { [weak self] _ in
            self?.currentLocation()
        }
        currentLocationButton.addAction(move, for: .touchUpInside)
    }
    
    private func setSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.placeholder = "검색할 장소를 입력해주세요."

        searchBar.searchTextField.layer.borderColor = UIColor(resource: .deepRose).cgColor
        searchBar.searchTextField.layer.borderWidth = 2
        searchBar.searchTextField.backgroundColor = .white.withAlphaComponent(0.5)
        searchBar.searchTextField.textColor = .secondaryText
    }
    
    private func setMapView(lat: Double, lng: Double) {
        mapView.mapType = .basic // 지도 유형 설정
        mapView.isNightModeEnabled = UITraitCollection.current.userInterfaceStyle == .dark // 다크모드 설정
        mapView.allowsTilting = false // 기울임 설정
        
        moveCameraPosition(lat: lat, lng: lng) // 카메라 포지션 변경 - 현재 위치를 비추도록
        
        // 현 위치 표시
        let locationOverlay = mapView.locationOverlay // 지도의 위치 오버레이
        locationOverlay.hidden = false // 오버레이 표시
        mapView.positionMode = .direction // 지도 화면이 현재 위치를 따라갈지 아닐지를 결정
    }
}


//MARK: MapView
extension MapViewController {
    // 지도를 비출 카메라 위치를 옮기는 메서드(== 표시될 지도의 위치를 변경하는 메서드)
    private func moveCameraPosition(lat: Double, lng: Double) {
        let cameraPosition = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
        cameraPosition.animation = didInitialized ? .fly : .none // 초기화 이후에만 애니메이션 적용
        
        mapView.moveCamera(cameraPosition) // 지도의 중앙이 cameraPosition 좌표가 되는 지도를 표시
    }
    
    //MARK: 마커의 생성과 배치
    /*
     네이버 지도의 오버레이 객체는 아무 스레드에서 생성할 수 있으나 오버레이의 속성은 스레드 안전성이 보장되지 않으므로 여러 스레드에서 동시에 접근해서는 안됩니다.
     특히, 지도에 추가된 오버레이의 속성은 메인 스레드에서만 접근해야합니다. (그렇지 않으면 크래시 발생)
     
     대량의 오버레이를 다룰 경우 객체를 생성하고 초기 옵션을 지정하는 작업은 백그라운드 스레드에서 수행하고,
     지도에 추가하는 작업만 메인스레드에서 수행하면 메인스레드를 효율적으로 사용 가능합니다.
     
     현재 프로젝트에서는 대량의 오버레이 객체를 다루지는 않지만 async await의 적용을 위해 두 작업을 나누어보았습니다.
     */
    
    // BackgroundActor 정의
    @globalActor actor BackgroundActor: GlobalActor {
        static let shared = BackgroundActor()
    }
    
    // 마커 생성 - 백그라운드 스레드에서 비동기적으로 동작
    @BackgroundActor
    private func makeMarkers(_ data: [(type: AnimalType, coordinate: Coordinate)]) async -> [NMFMarker] {
        return data.reduce(into: [NMFMarker]()) {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: $1.coordinate.latitude, lng: $1.coordinate.longitude) // 마커 좌표 설정 - 반드시 position을 정의한 후 마커를 배치해야함!
            
            // 마커 아이콘 설정
            switch $1.type {
            case .dog:
                marker.iconImage = NMFOverlayImage(image: .dogPin)
            case .cat:
                marker.iconImage = NMFOverlayImage(image: .catPin)
            case .pegasus:
                marker.iconImage = NMFOverlayImage(image: .pegasusPin)
            case .unicorn:
                marker.iconImage = NMFOverlayImage(image: .unicornPin)
            case .chocobo:
                marker.iconImage = NMFOverlayImage(image: .chocoboPin)
            }
            
            // 마커 사이즈
            marker.width = 30
            marker.height = 44
            
            marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                print("lat: \(marker.position.lat), lng: \(marker.position.lng)")
                return true // true값일 시, 이벤트를 지도로 전달하지 않음 (마커에서 이벤트를 소비)
            }
            
            $0.append(marker)
        }
    }
    
    // 마커 배치 - 반드시 메인 스레드에서 이뤄져야함
    @MainActor
    private func displayMarkers(_ markers: [NMFMarker]) {
        markers.forEach {
            $0.mapView = mapView
        }
    }
    
    func newRegister() {
        print("새로운 등록")
    }
}

//MARK: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    // 위치 정보 권한 상태 확인
    private func currentLocation() {
        if locationManager.authorizationStatus == .authorizedAlways
            || locationManager.authorizationStatus == .authorizedWhenInUse { // 위치 권한 허용시(항상 || 앱을 사용하는 동안)
            locationManager.requestLocation() // 현재 위치 정보
        } else if locationManager.authorizationStatus == .notDetermined { // 위치 권한 미지정시
            locationManager.requestWhenInUseAuthorization() // 권한 요청
        } else if locationManager.authorizationStatus == .denied {
            let alert = UIAlertController(status: .deniedAuth)
            present(alert, animated: true)
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
        
        guard let lat, let lng else { return }
        if didInitialized { // 맵뷰 초기 설정 이후일 경우
            viewModel.action(.didUpdateLocations(lat: lat, lng: lng))
        } else { // 맵뷰 초기 설정 이전일 경우
            viewModel.action(.initialized(lat: lat, lng: lng))
            didInitialized = true // 초기화 여부 변경
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        currentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        let alert = UIAlertController(status: .invalidLocation)
        present(alert, animated: true)
    }
}
