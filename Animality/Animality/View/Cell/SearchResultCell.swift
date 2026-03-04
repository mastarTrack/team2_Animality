//
//  SearchResultCell.swift
//  Animality
//
//  Created by t2025-m0143 on 3/3/26.
//
import UIKit
import Then
import SnapKit

class SearchResultCell: UICollectionViewListCell {
    static let identifier = "SearchResultCell"
    
    //MARK: Set Attributes
    // 이미지
    private let imageView = UIImageView().then {
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(systemName: "photo")
    }
    
    // 이름 레이블
    private let nameLabel = UILabel().then {
        $0.textColor = .text
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true // 공간 부족시 폰트 크기 조정 허용
        $0.minimumScaleFactor = 0.7 // 최소 폰트 크기 (최초 설정 크기인 14의 0.7배)
    }
    
    // 주소 레이블
    private let addressLabel = UILabel().then {
        $0.textColor = .secondaryText
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .left
        
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true // 공간 부족시 폰트 크기 조정 허용
        $0.minimumScaleFactor = 0.7 // 최소 폰트 크기 (최초 설정 크기인 14의 0.7배)
    }
//    private let telephoneLabel = UILabel().then {
//        $0.textColor = .text
//        $0.font = .systemFont(ofSize: 13, weight: .regular)
//        $0.textAlignment = .left
//        $0.adjustsFontSizeToFitWidth = true // 공간 부족시 폰트 크기 조정 허용
//        $0.minimumScaleFactor = 0.7 // 최소 폰트 크기 (최초 설정 크기인 14의 0.7배)
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: set Layout
extension SearchResultCell {
    private func setLayout() {
        let labelStack = makeLabelStack()
        
        contentView.addSubview(imageView)
        contentView.addSubview(labelStack)
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(64)
            $0.trailing.verticalEdges.equalToSuperview().inset(10)
        }
        
        labelStack.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(10)
            $0.trailing.equalTo(imageView.snp.leading).offset(-10)
        }
    }
    
    private func makeLabelStack() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, addressLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }
}

extension SearchResultCell {
    func configure(data: LocationInfo) {
        nameLabel.attributedText = data.name
        addressLabel.text = data.address
    }
}
