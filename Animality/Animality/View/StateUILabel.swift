//
//  StateUILabel.swift
//  Animality
//
//  Created by Hanjuheon on 2/27/26.
//

import UIKit

/// 상태 UILabel
class StateUILabel: UILabel {
    private let padding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    enum state: String {
        case completed
        case renting
        case cancel
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = .systemFont(ofSize: 14)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUIForReceipt(state: state, _ inputFont: UIFont?) {
        switch state {
        case .completed:
            backgroundColor = UIColor(hexCode: "#DCFCE7")
            textColor = UIColor(hexCode: "#008236")
            text = "랜트 완료"
        case .renting:
            backgroundColor = UIColor(hexCode: "#DBEAFE")
            textColor = UIColor(hexCode: "#1D4ED8")
            text = "렌트 중"
            
        case .cancel:
            backgroundColor = UIColor(hexCode: "#FEE2E2")
            textColor = UIColor(hexCode: "#DC2626")
            text = "취소"
        }
        guard let inputFont = inputFont else {
            return
        }
        font = inputFont
    }
    
    func updateUIForRegist(state: AnimalStatus, _ inputFont: UIFont?) {
        switch state {
        case .normal:
            backgroundColor = UIColor(hexCode: "#DCFCE7")
            textColor = UIColor(hexCode: "#008236")
            text = "한가해요"
        case .resting:
            backgroundColor = UIColor(hexCode: "#DCFCE7")
            textColor = UIColor(hexCode: "#008236")
            text = "바빠요"
        case .rented:
            backgroundColor = UIColor(hexCode: "#DBEAFE")
            textColor = UIColor(hexCode: "#1D4ED8")
            text = "쉬어요"
        case .sick:
            backgroundColor = UIColor(hexCode: "#FEE2E2")
            textColor = UIColor(hexCode: "#DC2626")
            text = "아파요"
        }
        guard let inputFont = inputFont else {
            return
        }
        font = inputFont
    }
}

extension StateUILabel {
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        return contentSize
    }
}

extension StateUILabel {
    func updateUIForSheet(status: AnimalStatus) {
        backgroundColor = UIColor(hexCode: "#E5E7EB")
        textColor = UIColor(hexCode: "#4A5565")
        
        switch status {
        case .normal:
            backgroundColor = UIColor(hexCode: "#DCFCE7")
            textColor = UIColor(hexCode: "#008236")
            text = "한가해요"
        case .rented:
            text = "바빠요"
        case .resting:
            text = "쉬어요"
        case .sick:
            text = "아파요"
        }
    }
}

@available(iOS 17.0, *)
#Preview{
    StateUILabel()
}
