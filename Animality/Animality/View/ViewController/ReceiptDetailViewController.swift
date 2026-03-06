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
    
    //MARK: - Enum
    enum pageType {
        case detail
        case endPay
    }
    
    // MARK: - State
    private let type: pageType
    private let receipt: RentReceipt
    
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
        title = "상세 내역"
        bindingButtonAction(type: type)
        ConfigureUI(type: type)
        ConfigureMapView()
        
        updateUI(rentState: receipt.rentState
                 , amount: receipt.amount
                 , name: receipt.animal?.name ?? "알수 없음"
                 , locationName: receipt.location ?? ""
                 , location: receipt.animal?.currentLocation ?? nil
                 , rentpaymentTime: receipt.rentPaymentTime
                 , rentStartTime: receipt.rentStartTime
                 , rentEndTime: receipt.rentEndTime
                 , paystate: receipt.payState
        )
        
        guard let animal = receipt.animal else { return }

        Task {
            await makeMarker(animalData: animal)
        }
    }
    
    init(type: pageType, receipt: RentReceipt) {
        self.type = type
        self.receipt = receipt
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - METHOD: Update UI
extension ReceiptDetailViewController {
    // UI 업데이트 메소드
    func updateUI(rentState: StateUILabel.RentState,
                  amount: Int64,
                  name: String,
                  locationName: String,
                  location: Coordinate?,
                  rentpaymentTime: Date,
                  rentStartTime: Date,
                  rentEndTime: Date,
                  paystate: StateUILabel.RentState
    ) {
        stateLabel.updateUIForReceipt(state: rentState,payState: false, nil)
        totalAmountLabel.text = NumberFormatter.localizedString(from: amount as NSNumber, number: .currency)
        rentLocationLabel.text = location?.formatted ?? "알수없음"
        nameLabel.text = name
        rentLocationLabel.text = locationName
        rentpaymentTimeLabel.text = rentpaymentTime.formatted()
        rentStartTimeLabel.text = rentStartTime.formatted()
        rentEndTimeLabel.text = rentEndTime.formatted()
        payState.updateUIForReceipt(state: paystate,payState: true, nil)
    }
}

//MARK: - METHOD: Button Action Binding
extension ReceiptDetailViewController {
    
    private func bindingButtonAction(type: pageType) {
        if type == .endPay {
            mypageButton.addAction(UIAction { [weak self] _ in
                self?.navigationController?.popToRootViewController(animated: true)
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
extension ReceiptDetailViewController {
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

    }
    
    /// 지도를 비출 카메라 위치를 옮기는 메서드(== 표시될 지도의 위치를 변경하는 메서드)
    private func moveCameraPosition(lat: Double, lng: Double) {
        let cameraPosition = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng), zoomTo: 14)
        cameraPosition.animation = .fly
        mapView.moveCamera(cameraPosition) // 지도의 중앙이 cameraPosition 좌표가 되는 지도를 표시
    }
    
    /// 마커 생성 메소드
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
}

//MARK: - METHOD: Configure UI
extension ReceiptDetailViewController {
    private func ConfigureUI(type: pageType) {
       
        let scrollView = UIScrollView()
        let contentView = UIView()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let reciptView = UIView().then {
            $0.backgroundColor = .lightRose
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
    let receipt = RentReceipt.sample1
    let vc = ReceiptDetailViewController(type: .endPay, receipt: receipt)
    return vc

}


