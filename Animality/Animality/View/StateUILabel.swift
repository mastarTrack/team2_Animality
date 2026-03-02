//
//  StateUILabel.swift
//  Animality
//
//  Created by Hanjuheon on 2/27/26.
//

import UIKit

/// 상태 UILabel
class StateUILabel: UILabel {
    
    enum states {
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
    
    func updateUI(state: states, _ inputFont: UIFont?) {
        switch state {
        case .completed:
            backgroundColor = UIColor(hexCode: "#DCFCE7")
            textColor = UIColor(hexCode: "#008236")
            text = "Completed"
        case .renting:
            backgroundColor = UIColor(hexCode: "#DBEAFE")
            textColor = UIColor(hexCode: "#1D4ED8")
            text = "Renting"
            
        case .cancel:
            backgroundColor = UIColor(hexCode: "#FEE2E2")
            textColor = UIColor(hexCode: "#DC2626")
            text = "Cancel"
        }
        guard let inputFont = inputFont else {
            return
        }
        font = inputFont
    }
}

@available(iOS 17.0, *)
#Preview{
    StateUILabel()
}
