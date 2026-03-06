//
//  SheetAnimalHeaderView.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//
import UIKit
import Then
import SnapKit

final class HeaderView: UICollectionReusableView {
    let label = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
