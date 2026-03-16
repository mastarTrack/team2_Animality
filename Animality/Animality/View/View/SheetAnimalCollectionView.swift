//
//  PinSheetView.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//
import UIKit
import SnapKit

class SheetAnimalCollectionView: UICollectionView {
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        setAttributes()
        collectionViewLayout = makeCollectionViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setAttributes() {
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20) // 양옆 마진만 줌
        contentInset = .init(top: 40, left: 0, bottom: 0, right: 0)
    }
    
    // 컬렉션뷰 레이아웃 설정
    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.contentInsetsReference = .layoutMargins // 여백
        
      return UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, environment in
          let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(28)
            ),
            elementKind: "HeaderKind",
            alignment: .top
          )
          
          // 여백 설정
          let spacing: CGFloat = 12
          
          // CollectionView 사이즈
          let containerSize = environment.container.effectiveContentSize
          
          // Item 설정
          let itemSize = containerSize.width
          let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(itemSize),
                heightDimension: .absolute(itemSize * 0.3)
            )
          )
          
          // Group 설정
          let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(itemSize),
                heightDimension: .fractionalHeight(1)
            ),
            subitems: [item]
          )
          
          group.interItemSpacing = .fixed(spacing)
          
          // Section 설정
          let section = NSCollectionLayoutSection(group: group)
          section.boundarySupplementaryItems = [headerItem]
          section.contentInsets = .init(top: 10, leading: 0, bottom: 0, trailing: 0) // 헤더 - 컨텐츠 간 여백 설정
          
          return section
      }, configuration: configuration)
    }
}
