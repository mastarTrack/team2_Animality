//
//  Untitled.swift
//  Animality
//
//  Created by Hanjuheon on 2/27/26.
//

import UIKit
import Then
import SnapKit
import NMapsMap
import NMapsGeometry

/// 영수증 ViewController
class ReceiptDetailViewController: UIViewController {
    
    //MARK: - ViewModel
    /// ViewModel
    private let vm: any ViewModelProtocol
    /// 지도 위치 매니저 클래스
    private let locationManager = CLLocationManager()
    
    //MARK: - Enum
    enum pageType {
        case detail
        case endPay
    }
    
    // MARK: - State
    private let type: pageType
    
    //MARK: - Components
    /// 렌트 상태 라벨
    private let stateLabel = StateUILabel()
    /// 결제금약 라벨
    private let totalAmountLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textAlignment = .right
    }
    /// 이름 라벨
    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    /// 대여 장소 라벨
    private let rentLocationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    /// 대여장소 지도 뷰
    private let mapView = NMFMapView(frame: .zero)
    /// 결제 시간 라벨
    private let rentpaymentTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    /// 대여 시작시간 라벨
    private let rentStartTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    /// 대여 종료시간 라벨
    private let rentEndTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    /// 결제상태 라벨
    private let payState = StateUILabel()
    
    /// 돌아가기 버튼
    private let returnButton = UIButton().then {
        $0.setTitle("돌아가기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 24
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    /// 이용내역 돌아가기 버튼
    private let mypageButton = UIButton().then {
        $0.setTitle("이용내역 보기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 24
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.systemGray.cgColor
    }
    

    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        currentLocation()
        bindingData()
        bindingButtonAction(type: type)
        ConfigureUI(type: type)
        ConfigureMapView()

        guard let vm = vm as? ReceiptDetailViewModel else { return }
        vm.action(.initialized)
    }
    
    init(type: pageType, vm: any ViewModelProtocol) {
        self.type = type
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - METHOD: Binding VM Action
extension ReceiptDetailViewController {
    // VM state 클로저 바인딩 메소드
    private func bindingData() {
        guard let vm = vm as? ReceiptDetailViewModel else { return }
        vm.stateChanged = { [weak self] state in
            guard let self else { return }
            
            switch state {
            case .none:
                break
            case let .updateUI(data):
                // UI 값 업데이트
                guard let animal = data.animal else { return }
                updateUI(rentState: data.rentState, amount: data.amount, name: animal.name , location: data.location ?? "", rentpaymentTime: data.rentPaymentTime, rentStartTime: data.rentEndTime, rentEndTime: data.rentEndTime, paystate: data.payState)
                // 마커 생성
                Task {
                    await self.makeMarker(animalData: animal)
                }
                
            }
        }
    }
}

//MARK: - METHOD: Update UI
extension ReceiptDetailViewController {
    // UI 업데이트 메소드
    func updateUI(rentState: StateUILabel.state,
                  amount: Int64,
                  name: String,
                  location: String,
                  rentpaymentTime: Date,
                  rentStartTime: Date,
                  rentEndTime: Date,
                  paystate: StateUILabel.state
    ) {
        stateLabel.updateUI(state: rentState, nil)
        totalAmountLabel.text = amount.formatted(.number)
        nameLabel.text = name
        rentLocationLabel.text = location
        rentpaymentTimeLabel.text = rentpaymentTime.formatted()
        rentStartTimeLabel.text = rentStartTime.formatted()
        rentEndTimeLabel.text = rentEndTime.formatted()
        payState.updateUI(state: paystate, nil)
    }
}

//MARK: - METHOD: Button Action Binding
extension ReceiptDetailViewController {
    
    private func bindingButtonAction(type: pageType) {
        if type == .endPay {
            mypageButton.addAction(UIAction { [weak self] _ in
           
            }, for: .touchUpInside)
        }
        returnButton.addAction(UIAction { [weak self] _ in
            self?.returnPage()
        }, for: .touchUpInside)
    }
    
    private func returnPage(){
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - METHOD: Configure MapView
extension ReceiptDetailViewController: CLLocationManagerDelegate {
    /// 지도 컴포넌트 초기화 메소드
    private func ConfigureMapView() {
        // 지도 타입 설정: 일반지도
        mapView.mapType = .basic
        // 다크 모드 설정: 현상태에 따른 다크모드 설정
        mapView.isNightModeEnabled = UITraitCollection.current.userInterfaceStyle == .dark // 다크모드 설정

        // 정적 지도로 만들기 위해 줌외의 기능 제외
        mapView.allowsTilting = false
        mapView.allowsScrolling = false
        mapView.allowsRotating = false
        
        // 지도 오버레이설정
        let locationOverlay = mapView.locationOverlay
        // 오버레이 IsHide: 오버레이 표시
        locationOverlay.hidden = false
        // 지도 화면이 현재 위치를 따라갈지 아닐지를 결정
        mapView.positionMode = .direction

        // 델리게이트 지정
        locationManager.delegate = self
        // 거리 정확도 설정 (설정하지 않을 시 kcLLocationAccuracyBest가 디폴트)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 이전 위치 대비 위치 업데이트 발동 간격 거리 설정(미터)
        locationManager.distanceFilter = 10
    }
    
    // 지도를 비출 카메라 위치를 옮기는 메서드(== 표시될 지도의 위치를 변경하는 메서드)
    private func moveCameraPosition(lat: Double, lng: Double) {
        let cameraPosition = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng), zoomTo: 14)
        cameraPosition.animation = .fly
        mapView.moveCamera(cameraPosition) // 지도의 중앙이 cameraPosition 좌표가 되는 지도를 표시
    }
    
    // 마커 생성 메소드
    private func makeMarker(animalData: Animal) async {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: animalData.currentLocation.latitude, lng: animalData.currentLocation.longitude)
        
        switch animalData.type {
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
        
        marker.width = 30
        marker.height = 44
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
        marker.mapView = mapView
        
        moveCameraPosition(lat: animalData.currentLocation.latitude,
                           lng: animalData.currentLocation.longitude)
    }
    
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
    
    /// 위치 권한 상태가 변경될 때 호출되는 Delegate 메서드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        currentLocation()
    }
    
    /// 위치 정보를 가져오는 과정에서 오류가 발생했을 때 호출되는 Delegate 메서드
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        let alert = UIAlertController(status: .invalidLocation)
        present(alert, animated: true)
    }
}

//MARK: - METHOD: Configure UI
extension ReceiptDetailViewController {
    private func ConfigureUI(type: pageType) {
       
        let scrollView = UIScrollView()
        let contentView = UIView()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let reciptView = UIView().then {
            $0.backgroundColor = .deepRose
            $0.layer.cornerRadius = 24
            $0.layer.borderColor = UIColor.systemGray.cgColor
            $0.layer.borderWidth = 0.5
        }
        
        let reciptStackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 4
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
        
        let payTitle = UILabel().then {
            $0.text = "💳 결제 금액"
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        let nameTitle = UILabel().then {
            $0.text = "🦮 개체 이름"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let locationTitle = UILabel().then {
            $0.text = "📌 대여 장소"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let rentPayDateTitle = UILabel().then {
            $0.text = "🗓️ 대여 일자"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let rentStartTitle = UILabel().then {
            $0.text = "⏱️ 시작 시간"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let rentEndTitle = UILabel().then {
            $0.text = "⏱️ 반납 시간"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let payStateTitle = UILabel().then {
            $0.text = "📊 결제 상태"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let lineViews = (0..<3).reduce(into: [UIView]()) { result, _ in
            let view = UIView().then {
                $0.backgroundColor = .systemGray
            }
            result.append(view)
        }
        
        let payStack = UIStackView(arrangedSubviews:[payTitle, totalAmountLabel])
        let nameStack = UIStackView(arrangedSubviews: [nameTitle, nameLabel])
        let locationStack = UIStackView(arrangedSubviews: [locationTitle, rentLocationLabel])
        let rentDateStack = UIStackView(arrangedSubviews: [rentPayDateTitle, rentpaymentTimeLabel])
        let rentStartStack = UIStackView(arrangedSubviews: [rentStartTitle, rentStartTimeLabel])
        let rentEndStack = UIStackView(arrangedSubviews: [rentEndTitle, rentEndTimeLabel])
        let payStateStack = UIStackView(arrangedSubviews: [payStateTitle, payState])
        
        [payStack, nameStack, locationStack, rentDateStack, rentStartStack, rentEndStack, payStateStack].forEach {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .fillEqually
        }
        
        reciptStackView.addArrangedSubview(payStack)
        reciptStackView.addArrangedSubview(lineViews[0])
        reciptStackView.addArrangedSubview(nameStack)
        reciptStackView.addArrangedSubview(locationStack)
        reciptStackView.addArrangedSubview(mapView)
        reciptStackView.addArrangedSubview(lineViews[1])
        reciptStackView.addArrangedSubview(rentDateStack)
        reciptStackView.addArrangedSubview(rentStartStack)
        reciptStackView.addArrangedSubview(rentEndStack)
        reciptStackView.addArrangedSubview(lineViews[2])
        reciptStackView.addArrangedSubview(payStateStack)
        reciptView.addSubview(reciptStackView)
        
        contentView.addSubview(stateLabel)
        contentView.addSubview(reciptView)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        stateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(122)
            $0.height.equalTo(36)
        }
        reciptView.snp.makeConstraints {
            $0.top.equalTo(stateLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(330)
            $0.height.equalTo(620)
        }
        reciptStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().inset(30)
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().inset(5)
        }
        
        mapView.snp.makeConstraints {
            $0.height.equalTo(250)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
        }
        
        [payStack, nameStack, locationStack, rentDateStack, rentStartStack, rentEndStack, payStateStack].forEach{
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(30)
                $0.trailing.equalToSuperview().inset(30)
            }
        }
        lineViews.forEach {
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(30)
                $0.trailing.equalToSuperview().inset(30)
                $0.height.equalTo(1)
            }
        }
        
        contentView.addSubview(returnButton)
        switch type {
        case .detail:
            returnButton.snp.makeConstraints {
                $0.top.equalTo(reciptView.snp.bottom).offset(30)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(45)
                $0.bottom.equalToSuperview().inset(20)

            }
        case .endPay:
            contentView.addSubview(mypageButton)
            mypageButton.snp.makeConstraints {
                $0.top.equalTo(reciptView.snp.bottom).offset(30)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(45)
            }
            returnButton.snp.makeConstraints {
                $0.top.equalTo(mypageButton.snp.bottom).offset(15)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(45)
                $0.bottom.equalToSuperview().inset(20)
            }
        }
    }
}




@available(iOS 17.0, *)
#Preview {
    let vm = ReceiptDetailViewModel()
    let vc = ReceiptDetailViewController(type: .endPay, vm: vm)
    return vc

}


