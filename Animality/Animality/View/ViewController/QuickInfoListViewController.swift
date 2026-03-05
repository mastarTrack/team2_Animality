//
//  QuickInfoListViewController.swift
//  Animality
//
//  Created by Hanjuheon on 3/2/26.
//

import UIKit
import Then
import SnapKit

/// 영수증 및 등록정보 목록 ViewController
class QuickInfoListViewController: UIViewController {
    
    //MARK: - ViewModel
     let vm: MyPageViewModel
    
    //MARK: - Enum
    enum CellType {
        case receipt
        case regist
    }

    //MARK: - Properties
    private var cellType: CellType
    
    
    //MARK: - Components
    /// 리스트 컬렉션 뷰
    var collectionView: UICollectionView?
    /// 리스트 없을시 표출하기위한 라벨
    var emptyLabel = UILabel().then {
        $0.text = "리스트가 없습니다."
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textColor = .systemGray
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        switch cellType {
        case .receipt:
            title = "이용 내역"
        case .regist:
            title = "등록 내역"
        }
        configureUI()
    }
    
    /// 상세뷰 Detail에서 삭제하고 돌아오면 리스트를 다시 갱신
    override func viewWillAppear(_ animated: Bool) {
        vm.action(.fetchReceipt)
        vm.action(.fetchRegistAnimal)
        super.viewWillAppear(animated)
    }
    

    
    init(cellType: CellType, vm: MyPageViewModel) {
        self.cellType = cellType
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - METHOD: Binding VM Action
extension QuickInfoListViewController {
    // VM state 클로저 바인딩 메소드
    private func bindingData() {
        vm.stateChanged = { [weak self] state in
            guard let self,
            let collectionView = collectionView else { return }
            
            switch state {
            case .none:
                break
            case .updateUI:
                collectionView.reloadData()
            }
        }
    }
}


// MARK: - METHOD: CollectionView
extension QuickInfoListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch cellType {
        case .receipt:
            return vm.modelManager.user.rentReceipt?.count ?? 0
        case .regist:
            return vm.modelManager.user.registAnimal?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReceiptCell.identifier, for: indexPath) as! ReceiptCell
        
        switch cellType {
        case .receipt:
            cell.updateUIForType(type: .receipt)
            guard let receipt = vm.modelManager.user.rentReceipt?[indexPath.item] else {
                return cell
            }
            cell.updateUIForReceipt(name: receipt.animal?.name ?? ""
                                    , state: receipt.rentState
                                    , location: receipt.location ?? ""
                                    , startTime: receipt.rentStartTime
                                    , endTime: receipt.rentEndTime
                                    , amount: Int(receipt.amount))
        case .regist:
            cell.updateUIForType(type: .regist)
            guard let animal = vm.modelManager.user.registAnimal?[indexPath.item] else {
                return cell
            }
            cell.updateUIForRegist(name: animal.name
                                   , state: animal.status
                                   , startTime: Date()
                                   , amount: animal.pricePerHour
            )
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch cellType {
        case .regist:
            guard let animal = vm.modelManager.user.registAnimal?[indexPath.item] else { return }
            // 같은 CoreDataManager를 Detail VM에 주입해줌
            let vm = DetailViewModel(coreDataManager: vm.coreDataManager)
            let detailVC = DetailViewController(animalID: animal.id, viewModel: vm)
            // 네비게이션 push
            navigationController?.pushViewController(detailVC, animated: true)
            
        case .receipt:
            guard let receipt = vm.modelManager.user.rentReceipt?[indexPath.item] else { return }
            let receiptVC = ReceiptDetailViewController(type: .detail, receipt: receipt)
            navigationController?.pushViewController(receiptVC, animated: true)
            return
        }
    }
    
}

//MARK: - METHOD: Compositional Layout
extension QuickInfoListViewController {
    private func getSection() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(313), heightDimension: .estimated(196)))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .estimated(313), heightDimension: .estimated(196)), subitems: [item])
        
        
        let section = NSCollectionLayoutSection(group: group)
        let itemWidth: CGFloat = 353
        let horizontalInset = (UIScreen.main.bounds.width - itemWidth) / 2
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: horizontalInset,
            bottom: 10,
            trailing: horizontalInset
        )
        section.interGroupSpacing = 16 
        return section
    }
    
}

// MARK: - 상태 매핑
private extension QuickInfoListViewController {
    func mapToReceiptState(_ statusString: String?) -> StateUILabel.state {
        // Optional일 수 있어서 안전 처리
        let status = statusString ?? ""

        switch status {
        case AnimalStatus.rented.rawValue:   // "대여중"
            return .renting
        default:
            return .completed
        }
    }
}

//MARK: - CONFIGURE UI
extension QuickInfoListViewController {
    private func configureUI() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(section: getSection()))
        
        
        guard let collectionView else {return}
        collectionView.register(ReceiptCell.self, forCellWithReuseIdentifier: ReceiptCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.trailing.equalToSuperview().inset(10)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.trailing.equalToSuperview().inset(10)
        }
    }
    
}


@available(iOS 17.0, *)
#Preview {
    let model = AnimalityModelManager(user: UserModel.sample, coreDataManager: CoreDataManager())
    let vm = MyPageViewModel(modelManager: model)
    QuickInfoListViewController(cellType: .regist, vm: vm)
}
