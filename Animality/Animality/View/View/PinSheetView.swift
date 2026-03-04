//
//  PinSheetView.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//
import UIKit

class PinSheetView: UISheetPresentationController {
    private lazy var listView = UICollectionView(frame: .zero, collectionViewLayout: makeCompositionalLayout())
    private lazy var dataSource = makeCollectionViewDiffableDataSource(listView)
    
    // 레이아웃 설정
    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            
            // 섹션 배경색 설정
            configuration.backgroundColor = .clear
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            return section
        }
    }
    
    // DiffableDataSource 설정
    private func makeCollectionViewDiffableDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, Animal> {
        let listCellRegistration = UICollectionView.CellRegistration<SheetAnimalCell, Animal> { (cell, indexPath, item) in
            cell.configure()
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Int, Animal>(collectionView: listView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        return dataSource
    }
    
    // 스냅샷 설정
    private func setSnapshot(with data: [Animal]) {
        var snapShot = NSDiffableDataSourceSnapshot<Int, Animal>()
        snapShot.appendSections([0])
        snapShot.appendItems(data, toSection: 0)
        self.dataSource.apply(snapShot)
    }
}
