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
    private let viewModel: LocationViewModel
    
    private let mapView = NMFMapView(frame: .zero)
    private var displayedMarkers = [NMFMarker]()
    
    private let searchBar = UISearchBar()
    private let currentLocationButton = UIButton()
    
    private lazy var listView = UICollectionView(frame: .zero, collectionViewLayout: makeCompositionalLayout())
    private lazy var dataSource = makeCollectionViewDiffableDataSource(listView)
    
    private var didInitialized = false // 초기화 여부
    
    //MARK: init
    init(modelManager: AnimalityModelManager) {
        self.viewModel = LocationViewModel(modelManager: modelManager, networkManager: NetworkManager())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindingData()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 거리 정확도 설정 (설정하지 않을 시 kcLLocationAccuracyBest가 디폴트)
        searchBar.delegate = self
        listView.delegate = self
        
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
                    self.displayedMarkers = await self.makeMarkers(data) // 마커 할당
                    self.displayMarkers(self.displayedMarkers)
                }
                
            case let .locationChanged(lat, lng): // 위치 이동 시
                moveCameraPosition(lat: lat, lng: lng)

            case let .newRegister(data):
                let new = compareNewMarkers(data) // 마커 생성 대상 찾기
                
                Task {
                    let newMarkers = await self.makeMarkers(new) // 마커 생성
                    self.displayMarkers(newMarkers) // 신규 마커 배치
                    self.displayedMarkers += newMarkers // 현재 마커 배열 갱신
                }

            case let .searched(result):
                Task {
                    await self.updateSearchResult(result)
                }
                
            case .cancelledSearch:
                Task {
                    await self.updateSearchResult([])
                }
                
            case .none:
                break
            }
        }
    }
}

//MARK: Set Layout & Attributes
extension MapViewController {
    // 레이아웃 설정
    private func setLayout() {
        view.addSubview(mapView)
        view.addSubview(searchBar)
        view.addSubview(listView)
        view.addSubview(currentLocationButton)
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints {
             $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        listView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(252)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.bottom.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.width.height.equalTo(56)
        }
    }
    
    // 속성 설정
    private func setAttributes() {
        self.navigationController?.navigationBar.isHidden = true
        setSearchBar()
        setButton()
        currentLocation()
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
            self?.currentLocation()
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
        listView.backgroundColor = .clear
        listView.showsVerticalScrollIndicator = false
        listView.layer.cornerRadius = 15
    }
    
    // 맵뷰 설정
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
                self?.showSheet(with: element.key)
                return true // true값일 시, 이벤트를 지도로 전달하지 않음 (마커에서 이벤트를 소비)
            }
            
            arr.append(marker)
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
        viewModel.action(.newRegister)
        print("새로운 등록")
    }
    
    // 마커 삭제
    @MainActor
    private func deleteMarkers(_ markers: [NMFMarker]) {
        markers.forEach {
            $0.mapView = nil // 마커 제거
        }
        
        //        // 마커 배열 갱신
        //        markers.removeAll {
        //            $0.mapView == nil
        //        }
    }
    
    // 생성 대상 비교
    private func compareNewMarkers(_ data: [Coordinate: AnimalType]) -> [Coordinate: AnimalType] {
        // 기존 마커 좌표 Set
        let exist = Set(displayedMarkers.map { Coordinate(latitude: $0.position.lat, longitude: $0.position.lng) })
        // 기존 마커 좌표에 없는 data들을 반환
        return data.filter { !exist.contains($0.key) }
        
    }
    
    // 삭제 대상 비교
    private func compareDeleteMarkers(_ data: [Coordinate: AnimalType]) -> [NMFMarker] {
        return displayedMarkers.reduce(into: [NMFMarker]()) {
            // 현재 비교 중인 기존 마커의 좌표
            let coordinate = Coordinate(latitude: $1.position.lat, longitude: $1.position.lng)
            
            // 업데이트된 마커 리스트에 해당 좌표가 없는 경우 삭제 대상에 추가
            data[coordinate] == nil ? $0.append($1) : ()
            }
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
    
    // 권한 변경 시 호출되는 함수
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        currentLocation() // 현재 위치로 카메라 이동
    }
    
    // 오류 발생 시 호출되는 함수
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        let alert = UIAlertController(status: .invalidLocation)
        present(alert, animated: true)
    }
}

//MARK: SheetView
extension MapViewController {
    func showSheet(with coordinate: Coordinate) {
        let sheet = PinSheetView(viewModel: viewModel, coordinate: coordinate)
        
        if let sheet = sheet.sheetPresentationController {
            sheet.detents = [.medium(), .large()] // 시트 크기
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true // 시트 확장 가능 여부
            sheet.prefersGrabberVisible = true // grabber 표시 여부
        }
        
        self.present(sheet, animated: true)
    }
}

//MARK: SearchBar
extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let origin = searchBar.text else { return }
        let text = origin.trimmingCharacters(in: .whitespaces) // 공백 제거
        
        if !text.isEmpty { // 텍스트가 공백이 아닐 시 검색
            viewModel.action(.search(text: text))
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            searchBar.showsCancelButton = true // textField에 글자 존재 시 취소 버튼을 표시
        }
    }
    
    // 취소 버튼 클릭 시 동작 - 검색 결과 지우기
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.action(.cancelSearch)
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}

//MARK: ListView
extension MapViewController {
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
    
    // DiffableDataSource 설정
    private func makeCollectionViewDiffableDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, LocationInfo> {
        let listCellRegistration = UICollectionView.CellRegistration<SearchResultCell, LocationInfo> { (cell, indexPath, item) in
            cell.configure(data: item)
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Int, LocationInfo>(collectionView: listView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        return dataSource
    }
    
    // 스냅샷 설정
    private func setSnapshot(with data: [LocationInfo]) {
        var snapShot = NSDiffableDataSourceSnapshot<Int, LocationInfo>()
        snapShot.appendSections([0])
        snapShot.appendItems(data, toSection: 0)
        self.dataSource.apply(snapShot)
    }
    
    // 검색 결과 업데이트
    @MainActor
    private func updateSearchResult(_ data: [LocationInfo]) async {
        listView.isHidden = data.isEmpty
        setSnapshot(with: data)
    }
}

extension MapViewController: UICollectionViewDelegate {
    // 검색 결과 셀 클릭 시 해당 위치로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let x = data.mapX / 10000000 // 경도
        let y = data.mapY / 10000000 // 위도
        
        moveCameraPosition(lat: y, lng: x)
    }
}
