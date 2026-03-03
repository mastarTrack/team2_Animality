//
//  RegisterViewTest.swift
//  Animality
//
//  Created by 김주희 on 3/3/26.
//

import UIKit
import SnapKit
import Then

final class RegisterView: UIView {
    
    // MARK: - View → VC 클로저
    
    var onNameEntered: ((String?) -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onSizeSelected: ((AnimalSize) -> Void)?
    var onFlightSelected: ((FlightCapability) -> Void)?
    var onLocationTapped: (() -> Void)?
    var onRegisterTapped: (() -> Void)?
    var onPriceEntered: ((String?) -> Void)?
    var onTypeSelected: ((AnimalType) -> Void)?
    var onLocationSelected: ((Double, Double) -> Void)?
    
    
    // MARK: -- UI components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 상단 그라데이션 영역
    private let headerView = UIView().then {
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    // 그라데이션 그릴 도화지
    private let gradientLayer = CAGradientLayer()
    
    // 아이콘 이미지
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemBlue
        $0.alpha = 0.5
    }
    
    
    // 이름 입력
    private let nameTitleLabel = UILabel().then {
        $0.text = "이름"
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
    }
    
    private let nameTextField = UITextField().then {
        $0.placeholder = "이름을 입력하세요"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
        $0.addLeftPadding(12)
    }
    
    
    // 카테고리
    private let categoryTitleLabel = UILabel().then {
        $0.text = "카테고리"
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
    }
    
    private let rideButton = CategoryButton(title: "Ride", imageName: "bicycle")
    private let petButton = CategoryButton(title: "Pet", imageName: "pawprint.fill")
    
    
    // 종류 UI 컴포넌트 추가하기
    private let typeTitleLabel = UILabel().then {
        $0.text = "종류"
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
        $0.isHidden = true
    }
    
    private let typeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .fillEqually
        $0.isHidden = true
    }
    
    
    // 크기
    private let sizeTitleLabel = UILabel().then {
        $0.text = "크기"
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
    }
    
    private let smallButton = CategoryButton(title: "소형", imageName: "s.circle")
    private let mediumButton = CategoryButton(title: "중형", imageName: "m.circle")
    private let largeButton = CategoryButton(title: "대형", imageName: "l.circle")
    
    
    // 비행 여부
    private let flightTitleLabel = UILabel().then {
        $0.text = "비행 여부"
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
    }
    
    private let canFlyButton = CategoryButton(title: "비행 가능", imageName: "airplane")
    private let cannotFlyButton = CategoryButton(title: "비행 불가능", imageName: "xmark")
    
    
    // 가격
    private let priceTitleLabel = UILabel().then {
        $0.text = "시간당 가격"
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
    }
    
    private let priceTextField = UITextField().then {
        $0.placeholder = "숫자만 입력하세요"
        $0.keyboardType = .numberPad
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
        $0.addLeftPadding(12)
    }
    
    
    // 위치
    private let locationTitleLabel = UILabel().then {
        $0.text = "위치"
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
    }
    
    private let locationCardView = UIView().then {
        $0.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        $0.layer.cornerRadius = 14
    }
    
    private let locationIcon = UIImageView().then {
        $0.image = UIImage(systemName: "map")
        $0.tintColor = .systemBlue
        $0.contentMode = .scaleAspectFit
    }
    
    private let locationLabel = UILabel().then {
        $0.text = "등록할 위치를 지정해주세요."
        $0.textColor = .darkGray
        $0.font = .systemFont(ofSize: 15)
    }
    
    
    // 등록 버튼
    private let registerButton = UIButton(type: .system).then {
        $0.setTitle("등록하기", for: .normal)
        $0.backgroundColor = .systemGray4
        $0.titleLabel?.font = .systemFont(ofSize: 18)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 14
        $0.isEnabled = false
    }
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI() // addSubview
        setupLayout() // snp
        setupActions() // addTarget
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = headerView.bounds
    }
    
    
    // MARK: - Setup UI
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(iconImageView)
        
        [nameTitleLabel, nameTextField, categoryTitleLabel, rideButton, petButton, locationTitleLabel, locationCardView, registerButton, sizeTitleLabel, smallButton, mediumButton, largeButton, flightTitleLabel, canFlyButton, cannotFlyButton, priceTitleLabel, priceTextField, typeTitleLabel, typeStackView].forEach { contentView.addSubview($0) }
        
        [locationIcon, locationLabel].forEach { locationCardView.addSubview($0) }
        
    }
    
    
    // MARK: - Gradient
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        headerView.layer.insertSublayer(gradientLayer, at: 0) // 맨 뒤에 넣어야 아이콘이 보임
    }
    
    
    // MARK: - Layout
    
    private func setupLayout() {
        
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        // 헤더
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.width.equalTo(300)
        }
        
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(130)
        }
        
        // 이름
        nameTitleLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameTitleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        // 카테고리
        categoryTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
        }
        
        rideButton.snp.makeConstraints {
            $0.top.equalTo(categoryTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(25)
            $0.width.equalTo(petButton)
            $0.height.equalTo(60)
        }
        
        petButton.snp.makeConstraints {
            $0.top.equalTo(rideButton)
            $0.leading.equalTo(rideButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-25)
            $0.height.equalTo(rideButton)
        }
        
        // 종류
        typeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(rideButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
        }
        
        typeStackView.snp.makeConstraints {
            $0.top.equalTo(typeTitleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(25)
            $0.height.equalTo(50)
        }
        
        // 크기
        sizeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(typeStackView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
        }
        
        smallButton.snp.makeConstraints {
            $0.top.equalTo(sizeTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(25)
            $0.width.equalTo(mediumButton)
            $0.height.equalTo(50)
        }
        
        mediumButton.snp.makeConstraints {
            $0.top.equalTo(smallButton)
            $0.leading.equalTo(smallButton.snp.trailing).offset(12)
            $0.width.equalTo(largeButton)
            $0.height.equalTo(smallButton)
        }
        
        largeButton.snp.makeConstraints {
            $0.top.equalTo(smallButton)
            $0.leading.equalTo(mediumButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-25)
            $0.height.equalTo(smallButton)
        }
        
        // 비행
        flightTitleLabel.snp.makeConstraints {
            $0.top.equalTo(smallButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
        }
        
        canFlyButton.snp.makeConstraints {
            $0.top.equalTo(flightTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(25)
            $0.width.equalTo(cannotFlyButton)
            $0.height.equalTo(50)
        }
        
        cannotFlyButton.snp.makeConstraints {
            $0.top.equalTo(canFlyButton)
            $0.leading.equalTo(canFlyButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-25)
            $0.height.equalTo(canFlyButton)
        }
        
        // 가격
        priceTitleLabel.snp.makeConstraints {
            $0.top.equalTo(canFlyButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
        }
        
        priceTextField.snp.makeConstraints {
            $0.top.equalTo(priceTitleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        // 위치
        locationTitleLabel.snp.makeConstraints {
            $0.top.equalTo(priceTextField.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
        }
        
        locationCardView.snp.makeConstraints {
            $0.top.equalTo(locationTitleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(180)
        }
        
        locationIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(60)
            $0.size.equalTo(40)
        }
        
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(locationIcon.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        // registerButton 위치 수정
        registerButton.snp.remakeConstraints {
            $0.top.equalTo(locationCardView.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().inset(20)
        }
        
    }
    
    
    // MARK: -- Actions
    
    private func setupActions() {
        nameTextField.addTarget(self, action: #selector(nameChanged), for:  .editingChanged)
        
        rideButton.addTarget(self, action: #selector(rideTapped), for: .touchUpInside)
        
        petButton.addTarget(self, action: #selector(petTapped), for: .touchUpInside)
        
        smallButton.addTarget(self, action: #selector(smallTapped), for: .touchUpInside)
        mediumButton.addTarget(self, action: #selector(mediumTapped), for: .touchUpInside)
        largeButton.addTarget(self, action: #selector(largeTapped), for: .touchUpInside)
        
        priceTextField.addTarget(self, action: #selector(priceChanged), for: .editingChanged)
        
        canFlyButton.addTarget(self, action: #selector(canFlyTapped), for: .touchUpInside)
        cannotFlyButton.addTarget(self, action: #selector(cannotFlyTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(locationTapped))
        locationCardView.addGestureRecognizer(tap)
        
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }
    
    // objc
    @objc private func nameChanged(_ sender: UITextField) {
        onNameEntered?(sender.text)
    }
    
    @objc private func rideTapped() {
        selectCategory(isRide: true)
        configureIcon(image: "bicycle") // 상단에 아이콘 추가
        
        // Ride 카테고리의 버튼들 생성하기
        updateTypeSelection(for: "Ride")
        
        onCategorySelected?("Ride")
    }
    
    @objc private func petTapped() {
        selectCategory(isRide: false)
        configureIcon(image: "pawprint.fill")
        
        // Pet 카테고리의 버튼들 생성하기
        updateTypeSelection(for: "Pet")
        
        onCategorySelected?("Pet")
    }
    
    // 카테고리에 맞는 종류 버튼들을 만드는 함수
    func updateTypeSelection(for category: String) {
        // 기존에 생성된 버튼들 싹 지우기
        typeStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 해당 카테고리에 속하는 타입들만 필터링
        let filteredTypes = AnimalType.allCases.filter { $0.category == category }
        
        filteredTypes.forEach { type in
            let button = CategoryButton(title: type.rawValue, imageName: "pawprint")
            button.addAction(UIAction(handler: { [weak self] _ in
                self?.selectTypeButton(selectedButton: button, selectedType: type)
            }), for: .touchUpInside)
            typeStackView.addArrangedSubview(button)
        }
        
        // 숨겨놨던 영역 보이기
        typeTitleLabel.isHidden = false
        typeStackView.isHidden = false
    }
    
    private func selectTypeButton(selectedButton: CategoryButton, selectedType: AnimalType) {
        // StackView 안의 모든 버튼 선택 해제 후 클릭된 것만 선택
        typeStackView.arrangedSubviews.compactMap { $0 as? CategoryButton }.forEach {
            $0.setSelected($0 == selectedButton)
        }
        onTypeSelected?(selectedType) // VC에게 알림
    }
    
    @objc private func smallTapped() {
        selectSize(.small)
    }
    
    @objc private func mediumTapped() {
        selectSize(.medium)
    }
    
    @objc private func largeTapped() {
        selectSize(.large)
    }
    
    @objc private func priceChanged(_ sender: UITextField) {
        onPriceEntered?(sender.text)
    }
    
    private func selectSize(_ size: AnimalSize) {
        
        smallButton.setSelected(size == .small)
        mediumButton.setSelected(size == .medium)
        largeButton.setSelected(size == .large)
        
        onSizeSelected?(size)
    }
    
    
    @objc private func canFlyTapped() {
        selectFlight(.canFly)
    }
    
    @objc private func cannotFlyTapped() {
        selectFlight(.cannotFly)
    }
    
    private func selectFlight(_ capability: FlightCapability) {
        
        canFlyButton.setSelected(capability == .canFly)
        cannotFlyButton.setSelected(capability == .cannotFly)
        
        onFlightSelected?(capability)
    }
    
    @objc private func locationTapped() {
        onLocationTapped?()
    }
    
    @objc private func registerTapped() {
        onRegisterTapped?()
    }
    
    
    
    // MARK: -- UI 업데이트
    
    // 카테고리 선택 Bool값 전달
    private func selectCategory(isRide: Bool) {
        rideButton.setSelected(isRide)
        petButton.setSelected(!isRide)
    }
    
    // 상단 아이콘 UI
    func configureIcon(image: String) {
        iconImageView.image = UIImage(systemName: image)
    }
}

final class CategoryButton: UIButton {
    init(title: String, imageName: String) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        setImage(UIImage(systemName: imageName), for: .normal)
        
        tintColor = .systemGray
        setTitleColor(.label, for: .normal)
        
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray.cgColor
        
        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = .init(top: 0, left: -8, bottom: 0, right: 0)
        titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // 버튼 선택 UI
    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? UIColor.systemPink.withAlphaComponent(0.2) : .clear
        layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.systemGray4.cgColor
    }
}

extension UITextField {
    func addLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 0))
        leftView = paddingView
        leftViewMode = .always
    }
}

extension RegisterViewTest {
    // 등록 버튼 활성화/비활성화 상태 업데이트
    func updateRegisterButton(_ isEnabled: Bool) {
        registerButton.isEnabled = isEnabled
        registerButton.backgroundColor = isEnabled ? .systemPink : .systemGray4
    }
    
    // 성공 알림
    func showSuccess() {
        print("저장에 성공했습니다.")
    }
}
