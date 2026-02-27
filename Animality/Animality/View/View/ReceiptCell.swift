//
//  ReceiptCell.swift
//  Animality
//
//  Created by Hanjuheon on 2/27/26.
//

import SnapKit
import Then
import UIKit

class ReceiptCell: UICollectionViewCell {

    enum rentStates {
        case completed
        case renting
        case cancel
    }

    //MARK: - Components
    /// 대여 동물 이름 라벨
    private let nameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textColor = .text
    }

    /// 대여상태 라벨
    private let stateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
        
    }

    /// 대여장소 라벨
    private let locationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryText
    }

    /// 대여 시작시간 라벨
    private let rentStartTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .text
    }

    /// 대여 종료시간 라벨
    private let rentEndTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .text
    }

    /// 대여비용 라벨
    private let totalAmountLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18)
        $0.textColor = .accentBlue
    }

    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("ReceiptCell init coder Error")
    }
}

//MARK: - METHOD: Update UI
extension ReceiptCell {
    /// UI 텍스트 업데이트 메소드
    func updateUI(
        name: String,
        state: rentStates,
        location: String,
        startTime: Date,
        endTime: Date,
        amount: Int
    ) {
        nameLabel.text = name
        locationLabel.text = location
        rentStartTimeLabel.text = startTime.formatted()
        rentEndTimeLabel.text = endTime.formatted()
        totalAmountLabel.text = String(amount)
        
        switch state {
        case .Completed:
            stateLabel.backgroundColor = UIColor(hexCode: "#DCFCE7")
            stateLabel.textColor = UIColor(hexCode: "#008236")
            stateLabel.text = "Completed"
        case .Renting:
            stateLabel.backgroundColor = UIColor(hexCode: "#DBEAFE")
            stateLabel.textColor = UIColor(hexCode: "#1D4ED8")
            stateLabel.text = "Renting"

        case .Cancel:
            stateLabel.backgroundColor = UIColor(hexCode: "#FEE2E2")
            stateLabel.textColor = UIColor(hexCode: "#DC2626")
            stateLabel.text = "Cancel"
        }
    }
}

//MARK: - METHOD: Configure UI
extension ReceiptCell {
    /// UI 초기 설정 메소드
    private func configureUI() {
        
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        
        let titleStack = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fillProportionally
        }

        let nameStack = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.spacing = 5
        }

        let timeStack = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.alignment = .center
        }

        let startTimeStack = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.spacing = 5
        }

        let endTimeStack = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.spacing = 5
        }

        let amountStack = UIStackView().then {
            $0.axis = .horizontal
            $0.alignment = .center
        }

        let startTimeTitleLabel = UILabel().then {
            $0.text = "Start"
            $0.textColor = .secondaryText
            $0.font = .systemFont(ofSize: 16)
        }

        let endTimeTitleLabel = UILabel().then {
            $0.text = "End"
            $0.textColor = .secondaryText
            $0.font = .systemFont(ofSize: 16)
        }
        
        let amountLineView = UIView().then {
            $0.backgroundColor = .systemGray
        }
        
        let amountTitleLabel = UILabel().then {
            $0.text = "Total Amount"
            $0.textColor = .secondaryLabel
            $0.font = .systemFont(ofSize: 16)
        }
        

        nameStack.addArrangedSubview(nameLabel)
        nameStack.addArrangedSubview(locationLabel)

        titleStack.addArrangedSubview(nameStack)

        startTimeStack.addArrangedSubview(startTimeTitleLabel)
        startTimeStack.addArrangedSubview(rentStartTimeLabel)
        endTimeStack.addArrangedSubview(endTimeTitleLabel)
        endTimeStack.addArrangedSubview(rentEndTimeLabel)
        timeStack.addArrangedSubview(startTimeStack)
        timeStack.addArrangedSubview(endTimeStack)
        
        amountStack.addArrangedSubview(amountTitleLabel)
        amountStack.addArrangedSubview(totalAmountLabel)
        
        contentView.addSubview(stateLabel)
        contentView.addSubview(titleStack)
        contentView.addSubview(timeStack)
        contentView.addSubview(amountLineView)
        contentView.addSubview(amountStack)
        
        contentView.snp.makeConstraints{
            $0.center.equalToSuperview()
            $0.width.equalTo(313)
            $0.height.equalTo(196)
        }
        
        titleStack.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(18)
            $0.height.equalTo(51)
        }
        timeStack.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(18)
            $0.trailing.equalToSuperview().inset(18)
        }
        amountLineView.snp.makeConstraints {
            $0.top.equalTo(timeStack.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(18)
            $0.trailing.equalToSuperview().inset(18)
            $0.height.equalTo(1)
        }
        amountStack.snp.makeConstraints {
            $0.top.equalTo(amountLineView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(18)
            $0.trailing.equalToSuperview().inset(18)
        }
        
        stateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.trailing.equalToSuperview().inset(18)
            $0.height.equalTo(24)
            $0.width.equalTo(87)
        }
        
 
    }
}

@available(iOS 17.0, *)
#Preview {
    let cell = ReceiptCell()
    cell.frame = CGRect(x: 0, y: 0, width: 300, height: 150)
    cell.updateUI(
        name: "황금 유니콘",
        state: .Completed,
        location: "강남",
        startTime: Date(),
        endTime: Date(),
        amount: 120000
    )
    return cell
}
