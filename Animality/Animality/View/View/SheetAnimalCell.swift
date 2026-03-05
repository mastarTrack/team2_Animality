//
//  SheetAnimalCell.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//

import UIKit
import Then
import SnapKit

final class SheetAnimalCell: UICollectionViewCell {
    static let identifier = "SheetAnimalCell"
    
    //MARK: set Attributes
    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    
    private let typeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    
    private let statusLabel = StateUILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    private let unitLabel = UILabel().then {
        $0.text = "시간 당 요금"
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textAlignment = .center
    }
    
    //MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 2
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("ReceiptCell init coder Error")
    }
}

//MARK: configure
extension SheetAnimalCell {
    func configure(with animal: Animal) {
        nameLabel.text = animal.name
        typeLabel.text = animal.type.rawValue
        priceLabel.text = "\(animal.pricePerHour.formatted(.currency(code: "KRW")))"
        statusLabel.updateUIForSheet(status: animal.status)
        
        switch animal.status {
        case .normal:
            configureAvailableUI()
        default:
            configureUnAvailableUI()
        }
    }
    
    private func configureAvailableUI() {
        contentView.backgroundColor = .white
        contentView.layer.borderColor = UIColor(resource: .rose).cgColor
        nameLabel.textColor = .text
        typeLabel.textColor = .secondaryText
        unitLabel.textColor = .secondaryText
        priceLabel.textColor = .accentBlue
    }
    
    private func configureUnAvailableUI() {
        contentView.backgroundColor = UIColor(hexCode: "#F9FAFB")
        contentView.layer.borderColor = UIColor(resource: .serenity).cgColor
        nameLabel.textColor = .text
        typeLabel.textColor = .lightGray
        unitLabel.textColor = .lightGray
        priceLabel.textColor = .deepSerenity
    }
}

//MARK: methods
extension SheetAnimalCell {
    private func setLayout() {
        let nameStack = makeVerticalStack(of: [nameLabel, typeLabel])
        let infoStack = makeVerticalStack(of: [priceLabel, unitLabel, statusLabel])
        infoStack.alignment = .center
        
        contentView.addSubview(nameStack)
        contentView.addSubview(infoStack)
        
        nameStack.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(infoStack.snp.top)
        }
        
        infoStack.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func makeVerticalStack(of views: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }
}
