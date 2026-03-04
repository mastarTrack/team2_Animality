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
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let typeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .secondaryText
    }
    
    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .accentBlue
    }
    
    private let statusLabel = StateUILabel().then {
        $0.updateUI(state: .completed, .systemFont(ofSize: 12, weight: .medium))
    }
    
    //MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .white
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("ReceiptCell init coder Error")
    }
}

extension SheetAnimalCell {
    private func setLayout() {
        let unitLabel = UILabel().then {
            $0.text = "시간 당 요금"
            $0.textColor = .secondaryText
            $0.font = .systemFont(ofSize: 12, weight: .medium)
        }
        
        let nameStack = makeVerticalStack(of: [nameLabel, typeLabel])
        let infoStack = makeVerticalStack(of: [priceLabel, unitLabel, statusLabel])
        
        contentView.addSubview(nameStack)
        contentView.addSubview(infoStack)
        
        nameStack.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.top.equalTo(infoStack.snp.top)
        }
        
        infoStack.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func makeVerticalStack(of views: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }
    
    func configure(with animal: Animal) {
        nameLabel.text = animal.name
        typeLabel.text = animal.type.rawValue
        priceLabel.text = "\(animal.pricePerHour)" // 표시형식 바꿔야함
        configureStatusLabel(status: animal.status)
    }
    
    private func configureStatusLabel(status: AnimalStatus) {
        switch status {
        case .normal:
            statusLabel.updateUI(state: .completed, .systemFont(ofSize: 12, weight: .medium))
            statusLabel.text = "한가해요"
        case .rented:
            statusLabel.updateUI(state: .renting, .systemFont(ofSize: 12, weight: .medium))
            statusLabel.text = "바빠요"
        case .resting:
            statusLabel.updateUI(state: .renting, .systemFont(ofSize: 12, weight: .medium))
            statusLabel.text = "쉴래요"
        case .sick:
            statusLabel.updateUI(state: .renting, .systemFont(ofSize: 12, weight: .medium))
            statusLabel.text = "아파요"
            
        }
    }
}
