//
//  PinSheetView.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//
import UIKit
import SnapKit

class PinSheetView: UIViewController {
    private let viewModel: any ViewModelProtocol
    private let coordinate: Coordinate
    private let animals: [Animal]
    
    private lazy var animalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
    private lazy var dataSource = makeCollectionViewDiffableDataSource(animalCollectionView)
    
    init(viewModel: LocationViewModel, coordinate: Coordinate) {
        self.animals = viewModel.coordinates[coordinate] ?? []
        self.viewModel = viewModel
        self.coordinate = coordinate
        print(animals)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setLayout()
        setSnapshot(with: animals)
    }
}

extension PinSheetView {
    private func setLayout() {
        animalCollectionView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20) // 양옆 마진만 줌
        animalCollectionView.contentInset = .init(top: 40, left: 0, bottom: 0, right: 0)
        view.addSubview(animalCollectionView)
        
        animalCollectionView.snp.makeConstraints {
            $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

//MARK: set CollectionView
extension PinSheetView {
    // 레이아웃 설정
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
    
    // DiffableDataSource 설정
    private func makeCollectionViewDiffableDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, Animal> {
        let cellRegistration = UICollectionView.CellRegistration<SheetAnimalCell, Animal> { (cell, indexPath, item) in
            cell.configure(with: item)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderView>(elementKind: "HeaderKind") { supplementaryView, elementKind, indexPath in
            supplementaryView.label.text = "한가한 동물들"
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Int, Animal>(collectionView: animalCollectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        dataSource.supplementaryViewProvider = {
            $0.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: $2)
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
