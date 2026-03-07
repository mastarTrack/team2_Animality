//
//  MapView.swift
//  Animality
//
//  Created by t2025-m0143 on 3/7/26.
//

import UIKit
import SnapKit
import NMapsMap
import CoreLocation

class AnimalityMapView: UIView {
    private let mapView = NMFMapView(frame: .zero)
    private var currentMarkers = [NMFMarker]()
    
    private(set) var searchBar = UISearchBar()
    private(set) lazy var listView = UICollectionView(frame: .zero, collectionViewLayout: makeCompositionalLayout())
    
    private let currentLocationButton = UIButton()
    
    //MARK: VC -> View Binding Closures
    var currentLocationButtonTapped: (() -> Void)?
    var markerTapped: ((Coordinate) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        setAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: Set Layout & Attributes
extension AnimalityMapView {
    // 레이아웃 설정
    private func setLayout() {
        addSubview(mapView)
        addSubview(searchBar)
        addSubview(listView)
        addSubview(currentLocationButton)
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints {
             $0.top.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
        }
        
        listView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(252)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.bottom.trailing.equalTo(safeAreaLayoutGuide).inset(10)
            $0.width.height.equalTo(56)
        }
    }
    
    // 속성 설정
    private func setAttributes() {
        setMapView()
        setSearchBar()
        setButton()
        setListView()
    }
    
    // 버튼 설정
    private func setButton() {
        // configuration
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .coralText
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        
        currentLocationButton.configuration = config
        currentLocationButton.configurationUpdateHandler = { button in
            let imageConfig = UIImage.SymbolConfiguration(weight: .bold) // 버튼에 표시될 이미지 두께 설정
            
            button.configuration?.image =
            button.isHighlighted ? UIImage(systemName: "location.fill")
            : UIImage(systemName: "location", withConfiguration: imageConfig)
        }
        
        // action
        let move = UIAction { [weak self] _ in
            self?.currentLocationButtonTapped?()
        }
        currentLocationButton.addAction(move, for: .touchUpInside)
    }
    
    // 검색바 설정
    private func setSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.placeholder = "검색할 장소를 입력해주세요."
        
        searchBar.searchTextField.layer.borderColor = UIColor(resource: .deepRose).cgColor
        searchBar.searchTextField.layer.borderWidth = 2
        searchBar.searchTextField.backgroundColor = .white.withAlphaComponent(0.5)
        searchBar.searchTextField.textColor = .secondaryText
    }
    
    // 주소 검색 결과 리스트뷰 설정
    private func setListView() {
        listView.isHidden = true
        listView.backgroundColor = nil
        listView.showsVerticalScrollIndicator = false
        listView.layer.cornerRadius = 15
    }
    
    // 맵뷰 설정
    private func setMapView() {
        mapView.mapType = .basic // 지도 유형 설정
        mapView.isNightModeEnabled = UITraitCollection.current.userInterfaceStyle == .dark // 다크모드 설정
        mapView.allowsTilting = false // 기울임 설정

        // 현 위치 표시
        let locationOverlay = mapView.locationOverlay // 지도의 위치 오버레이
        locationOverlay.hidden = false // 오버레이 표시
        mapView.positionMode = .direction // 지도 화면이 현재 위치를 따라갈지 아닐지를 결정
    }
}

extension AnimalityMapView {
    // 카메라 포지션 변경
    func moveCameraPosition(lat: Double, lng: Double, animate: Bool) {
        // 카메라 좌표
        let cameraPosition = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
        
        // 애니메이션 적용 여부
        cameraPosition.animation = animate ? .fly : .none
        
        // 지도 중앙이 cameraPosition이 되도록 지도를 표시
        mapView.moveCamera(cameraPosition)
    }
}

//MARK: MapView
extension AnimalityMapView {
    //MARK: 마커의 생성과 배치
    /*
     네이버 지도의 오버레이 객체는 아무 스레드에서 생성할 수 있으나 오버레이의 속성은 스레드 안전성이 보장되지 않으므로 여러 스레드에서 동시에 접근해서는 안됩니다.
     특히, 지도에 추가된 오버레이의 속성은 메인 스레드에서만 접근해야합니다. (그렇지 않으면 크래시 발생)
     
     대량의 오버레이를 다룰 경우 객체를 생성하고 초기 옵션을 지정하는 작업은 백그라운드 스레드에서 수행하고,
     지도에 추가하는 작업만 메인스레드에서 수행하면 메인스레드를 효율적으로 사용 가능합니다.
     
     현재 프로젝트에서는 대량의 오버레이 객체를 다루지는 않지만 async await의 적용을 위해 두 작업을 나누어보았습니다.
     */
    
    func setInitialMarkers(data: [Coordinate: AnimalType]) async {
        currentMarkers = await makeMarkers(data)
        displayMarkers(self.currentMarkers)
    }

    func addMarkers(data: [Coordinate: AnimalType]) async {
        let new = compareNewMarkers(data) // 마커 생성 대상 데이터
        let newMarkers = await makeMarkers(new) // 신규 생성 마커
        displayMarkers(newMarkers) // 배치
        
        currentMarkers += newMarkers // 현재 마커 갱신
    }
    
    func deleteMarkers(data: [Coordinate: AnimalType]) async {
        let delete = compareDeleteMarkers(data) // 마커 제거 대상 데이터
        removeMarkers(delete) // 마커 삭제
        currentMarkers.removeAll { $0.mapView == nil } // 현재 마커 갱신
    }
    
    // 마커 생성
    private func makeMarkers(_ data: [Coordinate: AnimalType]) async -> [NMFMarker] {
        return data.reduce(into: [NMFMarker]()) { arr, element in
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: element.key.latitude, lng: element.key.longitude) // 마커 좌표 설정 - 반드시 position을 정의한 후 마커를 배치해야함!
            
            // 마커 아이콘 설정
            switch element.value {
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
            
            marker.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
                self?.markerTapped?(element.key)
                return true // true값일 시, 이벤트를 지도로 전달하지 않음 (마커에서 이벤트를 소비)
            }
            
            arr.append(marker)
        }
    }
    
    // 마커 배치 - 반드시 메인 스레드에서 이뤄져야함, Actor로 분리하여 동시 접근을 방지
    @MainActor
    private func displayMarkers(_ markers: [NMFMarker]) {
        markers.forEach {
            $0.mapView = mapView
        }
    }
    
    // 마커 삭제
    @MainActor
    private func removeMarkers(_ markers: [NMFMarker]) {
        markers.forEach {
            $0.mapView = nil // 마커 제거
        }
    }
    
    // 생성 대상 비교
    private func compareNewMarkers(_ data: [Coordinate: AnimalType]) -> [Coordinate: AnimalType] {
        // 기존 마커 좌표 Set
        let exist = Set(currentMarkers.map { Coordinate(latitude: $0.position.lat, longitude: $0.position.lng) })
        // 기존 마커 좌표에 없는 data들을 반환
        return data.filter { !exist.contains($0.key) }
        
    }
    
    // 삭제 대상 비교
    private func compareDeleteMarkers(_ data: [Coordinate: AnimalType]) -> [NMFMarker] {
        return currentMarkers.reduce(into: [NMFMarker]()) {
            // 현재 비교 중인 기존 마커의 좌표
            let coordinate = Coordinate(latitude: $1.position.lat, longitude: $1.position.lng)
            
            // 업데이트된 마커 리스트에 해당 좌표가 없는 경우 삭제 대상에 추가
            data[coordinate] == nil ? $0.append($1) : ()
            }
    }
}

//MARK: ListView
extension AnimalityMapView {
    // 레이아웃 설정
    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            
            // 섹션 배경색 설정
            configuration.backgroundColor = .clear
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            return section
        }
    }
}
