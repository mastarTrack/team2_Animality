//
//  PinSheetViewController.swift
//  Animality
//
//  Created by t2025-m0143 on 3/7/26.
//
import UIKit
import SnapKit

class PinSheetViewController: UIViewController {
    private let viewModel: SheetViewModel
    
    private let collectionView = SheetAnimalCollectionView()
    private lazy var dataSource = makeCollectionViewDiffableDataSource(collectionView)
    
    init(viewModel: SheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setLayout()
        
        bindingData()
        collectionView.delegate = self
        
        viewModel.action(.initialized)
    }
}

extension PinSheetViewController {
    private func setLayout() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bindingData() {
        viewModel.stateChanged = { [weak self] state in
            self?.render(state)
        }
    }
    
    private func render(_ state: SheetViewModel.State) {
        switch state {
        case let .initialized(animals):
            setSnapshot(with: animals)
        case let .refreshed(animals):
            setSnapshot(with: animals)
        default:
            break
        }
    }
}

//MARK: set CollectionView
extension PinSheetViewController {
    // DiffableDataSource 설정
    private func makeCollectionViewDiffableDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, Animal> {
        let cellRegistration = UICollectionView.CellRegistration<SheetAnimalCell, Animal> { (cell, indexPath, item) in
            cell.configure(with: item)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderView>(elementKind: "HeaderKind") { supplementaryView, elementKind, indexPath in
            supplementaryView.label.text = "한가한 동물들"
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Int, Animal>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
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

extension PinSheetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let data = dataSource.itemIdentifier(for: indexPath)
        
        switch data?.status { // 동물의 상태
        case .normal:
            return true // 정상(대여 가능)일 경우: 셀 선택 가능
        default:
            return false // 이외의 경우: 셀 선택 불가
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let vc = PaymentViewController(animalID: data.id, modelManager: viewModel.modelManager) { [weak self] in
            self?.viewModel.action(.rented) // 동물 업데이트
            
            // 마이페이지 업데이트
            self?.navigationController?.popViewController(animated: true)
            guard let nav = self?.tabBarController?.viewControllers?.last as? UINavigationController else { return }
            guard let myVC = nav.viewControllers.first as? MyPageViewController else { return }
            myVC.vm.action(.fetchReceipt)
        }
        
        modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
