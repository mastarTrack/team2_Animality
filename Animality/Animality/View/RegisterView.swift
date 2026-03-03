//
//  RegisterViewTest.swift
//  Animality
//
//  Created by 김주희 on 3/3/26.
//

import UIKit
import SnapKit
import Then

final class RegisterViewTest: UIView {
    
    // MARK: - View → VC 클로저
    
    var onNameEntered: ((String?) -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onLocationTapped: (() -> Void)?
    var onRegisterTapped: (() -> Void)?

    
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
    }
    

    
    // 이름 입력
    private let nameTitleLabel = UILabel().then {
        $0.text = "이름"
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textColor = .systemGray
    }
    
    private let nameTextField = UITextField().then {
        $0.placeholder = "  이름을 입력하세요."
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
    }
    
    
    // 카테고리
    private let categoryTitleLabel = UILabel().then {
        $0.text = "카테고리"
        $0.font = .boldSystemFont(ofSize: 14)
    }
    
    private let rideButton = CategoryButton(title: "Ride", imageName: "bicycle")
    private let petButton = CategoryButton(title: "Pet", imageName: "pawprint")
    
    // 위치
    private let locationTitleLabel = UILabel().then {
        $0.text = "위치"
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textColor = .systemGray
    }
    
    private let locationCardView = UIView().then {
        $0.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        $0.layer.cornerRadius = 14
    }
    
    private let locationIcon = UIImageView().then {
        $0.image = UIImage(systemName: "mappin.circle")
        $0.tintColor = .systemBlue
        $0.contentMode = .scaleAspectFit
    }
    
    private let locationLabel = UILabel().then {
        $0.text = "등록 위치를 지정해주세요."
        $0.textColor = .systemBlue
        $0.font = .systemFont(ofSize: 14)
    }
    
    
    // 등록 버튼
    private let registerButton = UIButton(type: .system).then {
        $0.setTitle("등록하기", for: .normal)
        $0.backgroundColor = .systemGray4
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 14
        $0.isEnabled = false
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
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
        
        [nameTitleLabel, nameTextField, categoryTitleLabel, rideButton, petButton, locationTitleLabel, locationCardView, registerButton].forEach { contentView.addSubview($0) }
        
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
        
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.width.equalTo(270)
        }
        
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(80)
        }
        
        // 이름
        nameTitleLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameTitleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(15)
            $0.height.equalTo(48)
        }
        
        // 카테고리
        categoryTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        rideButton.snp.makeConstraints {
            $0.top.equalTo(categoryTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(petButton)
            $0.height.equalTo(60)
        }
        
        petButton.snp.makeConstraints {
            $0.top.equalTo(rideButton)
            $0.leading.equalTo(rideButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(rideButton)
        }
        
        // 위치
        locationTitleLabel.snp.makeConstraints {
            $0.top.equalTo(rideButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        locationCardView.snp.makeConstraints {
            $0.top.equalTo(locationTitleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(180)
        }
        
        locationIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(35)
            $0.size.equalTo(40)
        }
        
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(locationIcon.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
        }
        
        registerButton.snp.makeConstraints {
            $0.top.equalTo(locationCardView.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(560)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    
    // MARK: -- Actions
    
    private func setupActions() {
        nameTextField.addTarget(self, action: #selector(nameChanged), for:  .editingChanged)
        
        rideButton.addTarget(self, action: #selector(rideTapped), for: .touchUpInside)
        
        petButton.addTarget(self, action: #selector(petTapped), for: .touchUpInside)
        
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }
    
    @objc private func nameChanged(_ sender: UITextField) {
        onNameEntered?(sender.text)
    }
    
    @objc private func rideTapped() {
        selectCategory(isRide: true)
        configureIcon(image: "bicycle")
        onCategorySelected?("Ride")
    }
    
    @objc private func petTapped() {
        selectCategory(isRide: false)
        configureIcon(image: "pawprint")
        onCategorySelected?("Pet")
    }
    
    @objc private func registerTapped() {
        onRegisterTapped?()
    }
    
    
    
    // MARK: -- UI 업데이트
    
    private func selectCategory(isRide: Bool) {
        rideButton.setSelected(isRide)
        petButton.setSelected(!isRide)
    }
    
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
        layer.borderColor = UIColor.systemBlue.cgColor
        
        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = .init(top: 0, left: -8, bottom: 0, right: 0)
        titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? UIColor.systemPink.withAlphaComponent(0.2) : .clear
        layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.systemGray4.cgColor
    }
}

#Preview {
    RegisterViewController()
}
