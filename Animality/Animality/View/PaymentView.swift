//
//  PaymentView.swift
//  Animality
//
//  Created by 김주희 on 3/4/26.
//

import UIKit
import SnapKit
import Then

final class PaymentView: UIView {

    // MARK: - VC 전달용 클로저
    var onStartDateChanged: ((Date) -> Void)?
    var onEndDateChanged: ((Date) -> Void)?
    var onPayTapped: (() -> Void)?

    
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerView = UIView().then {
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }

    private let gradientLayer = CAGradientLayer()

    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemBlue
        $0.alpha = 0.4
    }
    
    // 동물 이름
    private let animalNameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textAlignment = .center
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    // 버튼 UI로 보여줄 태그들
    private let typeTag = InfoTagButton()
    private let sizeTag = InfoTagButton()
    private let flightTag = InfoTagButton()

    private let tagRow = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .fillEqually
    }

    // 주의사항 박스
    private let cautionBox = UIView().then {
        $0.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.25)
        $0.layer.cornerRadius = 14
    }

    private let cautionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .darkText
        $0.text =
"""
⚠️ 대여 주의사항

• 반납 시간을 초과하면 추가 요금이 발생할 수 있어요.
• 대여 중 파손/분실 시 책임이 발생할 수 있어요.
• 안전 규정을 꼭 지켜주세요.
"""
    }

    // 날짜 선택
    private let startTitle = UILabel().then {
        $0.text = "대여 시작 시간"
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
    }

    private let endTitle = UILabel().then {
        $0.text = "반납 시간"
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
    }

    private let startField = UITextField().then {
        $0.placeholder = "시작 시간을 선택하세요"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
        $0.addLeftPadding(12)
        $0.tintColor = .clear
    }

    private let endField = UITextField().then {
        $0.placeholder = "반납 시간을 선택하세요"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
        $0.addLeftPadding(12)
        $0.tintColor = .clear
    }

    private let startPicker = UIDatePicker().then {
        $0.datePickerMode = .dateAndTime
        $0.preferredDatePickerStyle = .wheels
    }

    private let endPicker = UIDatePicker().then {
        $0.datePickerMode = .dateAndTime
        $0.preferredDatePickerStyle = .wheels
    }

    // 결제 정보
    private let summaryBox = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 16
    }

    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.text = "시간당 가격"
    }

    private let priceValue = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textAlignment = .right
    }

    private let durationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.text = "대여 시간"
    }

    private let durationValue = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textAlignment = .right
    }

    private let totalLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .label
        $0.text = "총 결제 금액"
    }

    private let totalValue = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textAlignment = .right
        $0.textColor = .coralText
    }

    private let payButton = UIButton(type: .system).then {
        $0.setTitle("결제하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
        $0.backgroundColor = .systemGray4
        $0.layer.cornerRadius = 14
        $0.isEnabled = false
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGradient()
        setupPickers()
        setupActions()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = headerView.bounds
    }

    // MARK: -- setupUI
    private func setupUI() {
        backgroundColor = .systemBackground

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerView)
        headerView.addSubview(iconImageView)

        [animalNameLabel, tagRow, cautionBox,
         startTitle, startField, endTitle, endField,
         summaryBox, payButton].forEach { contentView.addSubview($0) }

        [typeTag, sizeTag, flightTag].forEach { tagRow.addArrangedSubview($0) }
        cautionBox.addSubview(cautionLabel)

        let row1 = makeRow(left: priceLabel, right: priceValue)
        let row2 = makeRow(left: durationLabel, right: durationValue)
        let row3 = makeRow(left: totalLabel, right: totalValue)

        [row1, row2, row3].forEach { summaryBox.addSubview($0) }

        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(240)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(120)
        }

        animalNameLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }

        tagRow.snp.makeConstraints {
            $0.top.equalTo(animalNameLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }

        cautionBox.snp.makeConstraints {
            $0.top.equalTo(tagRow.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }

        cautionLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(14)
        }

        startTitle.snp.makeConstraints {
            $0.top.equalTo(cautionBox.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(20)
        }
        startField.snp.makeConstraints {
            $0.top.equalTo(startTitle.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }

        endTitle.snp.makeConstraints {
            $0.top.equalTo(startField.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(20)
        }
        endField.snp.makeConstraints {
            $0.top.equalTo(endTitle.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }

        summaryBox.snp.makeConstraints {
            $0.top.equalTo(endField.snp.bottom).offset(22)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(140)
        }

        row1Layout(in: summaryBox.subviews[0])
        row2Layout(in: summaryBox.subviews[1])
        row3Layout(in: summaryBox.subviews[2])

        payButton.snp.makeConstraints {
            $0.top.equalTo(summaryBox.snp.bottom).offset(26)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // 그라데이션
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        headerView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupPickers() {
        startPicker.minimumDate = Date()
        endPicker.minimumDate = Date()

        startField.inputView = startPicker
        endField.inputView = endPicker

        startField.inputAccessoryView = makeToolbar()
        endField.inputAccessoryView = makeToolbar()

        startPicker.addTarget(self, action: #selector(startPickerChanged), for: .valueChanged)
        endPicker.addTarget(self, action: #selector(endPickerChanged), for: .valueChanged)
    }

    private func setupActions() {
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
    }

    @objc private func startPickerChanged() {
        let date = startPicker.date
        startField.text = date.formatted()
        onStartDateChanged?(date)

        // end 최소값 보정
        endPicker.minimumDate = date
        if endPicker.date <= date {
            endPicker.date = date.addingTimeInterval(3600)
            endField.text = endPicker.date.formatted()
            onEndDateChanged?(endPicker.date)
        }
    }

    @objc private func endPickerChanged() {
        let date = endPicker.date
        endField.text = date.formatted()
        onEndDateChanged?(date)
    }

    @objc private func payTapped() {
        onPayTapped?()
    }

    // MARK: - Render
    func render(state: PaymentViewModel.State) {
        guard let animal = state.animal else { return }

        animalNameLabel.text = animal.name
        
        // 카테고리별 아이콘
        iconImageView.image = UIImage(systemName: animal.type.category == "Ride" ? "bicycle" : "pawprint.fill")
        
        // 버튼 UI 표시
        typeTag.setTitle("종류: \(animal.type.rawValue)", for: .normal)
        sizeTag.setTitle("크기: \(animal.size.rawValue)", for: .normal)
        flightTag.setTitle(animal.flightCapability.rawValue, for: .normal)

        // 날짜
        startPicker.date = state.startDate
        endPicker.date = state.endDate
        startField.text = state.startDate.formatted()
        endField.text = state.endDate.formatted()
        endPicker.minimumDate = state.startDate

        // 요약
        priceValue.text = NumberFormatter.localizedString(from: animal.pricePerHour as NSNumber, number: .currency)
        durationValue.text = state.durationText
        totalValue.text = NumberFormatter.localizedString(from: state.totalAmount as NSNumber, number: .currency)

        // 버튼 활성화
        payButton.isEnabled = state.isPayEnabled
        payButton.backgroundColor = state.isPayEnabled ? .systemPink : .systemGray4
    }

    // MARK: - Helpers
    private func makeToolbar() -> UIToolbar {
        let bar = UIToolbar()
        bar.sizeToFit()
        let flex = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneTapped))
        bar.items = [flex, done]
        return bar
    }

    @objc private func doneTapped() {
        endEditing(true)
    }

    private func makeRow(left: UILabel, right: UILabel) -> UIView {
        let container = UIView()
        container.addSubview(left)
        container.addSubview(right)
        return container
    }

    private func row1Layout(in container: UIView) {
        priceLabel.snp.makeConstraints { $0.leading.centerY.equalToSuperview(); $0.top.bottom.equalToSuperview() }
        priceValue.snp.makeConstraints { $0.trailing.centerY.equalToSuperview(); $0.top.bottom.equalToSuperview() }
        container.snp.makeConstraints { $0.top.equalToSuperview().offset(14); $0.horizontalEdges.equalToSuperview().inset(14); $0.height.equalTo(28) }
    }

    private func row2Layout(in container: UIView) {
        durationLabel.snp.makeConstraints { $0.leading.centerY.equalToSuperview(); $0.top.bottom.equalToSuperview() }
        durationValue.snp.makeConstraints { $0.trailing.centerY.equalToSuperview(); $0.top.bottom.equalToSuperview() }
        container.snp.makeConstraints { $0.top.equalToSuperview().offset(54); $0.horizontalEdges.equalToSuperview().inset(14); $0.height.equalTo(28) }
    }

    private func row3Layout(in container: UIView) {
        totalLabel.snp.makeConstraints { $0.leading.centerY.equalToSuperview(); $0.top.bottom.equalToSuperview() }
        totalValue.snp.makeConstraints { $0.trailing.centerY.equalToSuperview(); $0.top.bottom.equalToSuperview() }
        container.snp.makeConstraints { $0.top.equalToSuperview().offset(94); $0.horizontalEdges.equalToSuperview().inset(14); $0.height.equalTo(34) }
    }
}

// MARK: - Tag Button
final class InfoTagButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        isUserInteractionEnabled = false
        setTitleColor(.label, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        backgroundColor = .clear
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
    }
}
