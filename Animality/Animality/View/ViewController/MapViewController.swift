//
//  MapViewController.swift
//  Animality
//
//  Created by t2025-m0143 on 2/27/26.
//
import UIKit
import SnapKit
import CoreLocation

class MapViewController: UIViewController {
    private let mapView = AnimalityMapView()
    
    private let locationManager = CLLocationManager()
    private let viewModel: LocationViewModel

    private lazy var dataSource = makeCollectionViewDiffableDataSource(mapView.listView)
    
    //MARK: init
    init(modelManager: AnimalityModelManager) {
        self.viewModel = LocationViewModel(modelManager: modelManager, networkManager: NetworkManager())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        bindingData()
        self.viewModel.action(.initialized)
        
        setDelegate()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 거리 정확도 설정 (설정하지 않을 시 kcLLocationAccuracyBest가 디폴트)
    }
    
    //MARK: View -> VM
    private func bindingData() {
        mapView.currentLocationButtonTapped = { [weak self] in
            self?.currentLocation()
        }
        
        mapView.markerTapped = { [weak self] coordinate in
            self?.showSheet(with: coordinate)
        }
        
        viewModel.stateChanged = { [weak self] state in
            Task {
                await self?.render(state)
            }
        }
    }
    
    //MARK: VM -> View (UI 변경)
    private func render(_ state: LocationViewModel.State) async {
        switch state {
        case let .initialized(data: data):
            // 마커 생성 및 배치
            await mapView.setInitialMarkers(data: data)
            currentLocation()
            
        case let .locationChanged(lat, lng, animate):
            mapView.moveCameraPosition(lat: lat, lng: lng, animate: animate)
            
        case let .newRegister(data: data):
            await mapView.addMarkers(data: data)
            
        case let .deleteRegistration(data: data):
            await mapView.deleteMarkers(data: data)
            
        case let .searched(result: result):
            setSnapshot(with: result)
            mapView.listView.isHidden = false
            
        case .noSearchResult:
            mapView.listView.isHidden = true
            notifyNoResult()
            
        case .cancelledSearch:
            setSnapshot(with: [])
            mapView.listView.isHidden = false
            
        case .none:
            break
        }
    }
    
    private func setDelegate() {
        locationManager.delegate = self
        mapView.searchBar.delegate = self
        mapView.listView.delegate = self
    }
}

//MARK: 외부 호출 메서드
extension MapViewController {
    func newRegister() {
        viewModel.action(.newRegister)
    }
    
    func deleteRegistration() {
        viewModel.action(.deleteRegistration)
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
        viewModel.action(.didUpdateLocations(lat: lat, lng: lng))
        
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
    private func showSheet(with coordinate: Coordinate) {
        let sheetVM = SheetViewModel(modelManager: viewModel.modelManager, coordinate: coordinate)
        let sheetVC = PinSheetViewController(viewModel: sheetVM)
        let nav = UINavigationController(rootViewController: sheetVC)
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()] // 시트 크기
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true // 시트 확장 가능 여부
            sheet.prefersGrabberVisible = true // grabber 표시 여부
        }
        
        present(nav, animated: true)
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
    // DiffableDataSource 설정
    private func makeCollectionViewDiffableDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, LocationInfo> {
        let listCellRegistration = UICollectionView.CellRegistration<SearchResultCell, LocationInfo> { (cell, indexPath, item) in
            cell.configure(data: item)
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Int, LocationInfo>(collectionView: mapView.listView) { collectionView, indexPath, itemIdentifier in
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
    
    @MainActor
    private func notifyNoResult() {
        let alert = UIAlertController(title: "검색 결과 없음", message: "검색 결과가 없습니다.", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)
        self.present(alert, animated: true)
    }
}

extension MapViewController: UICollectionViewDelegate {
    // 검색 결과 셀 클릭 시 해당 위치로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let x = data.mapX / 10000000 // 경도
        let y = data.mapY / 10000000 // 위도
        
        viewModel.action(.didUpdateLocations(lat: y, lng: x))
    }
}
