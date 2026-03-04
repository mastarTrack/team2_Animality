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
    
    // MARK: - Dependencies
    private let coreDataManager: CoreDataManager

    // MARK: - Data
    private var animals: [AnimalEntity] = []
    
    //MARK: - ViewModel
    
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

    // MARK: - Init
    init(coreDataManager: CoreDataManager = CoreDataManager()) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }


    //MARK: - Closures
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadData()
    }
    
    /// 상세뷰 Detail에서 삭제하고 돌아오면 리스트를 다시 갱신
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func loadData() {
        animals = coreDataManager.fetchAllAnimalEntities()
        emptyLabel.isHidden = !animals.isEmpty
        collectionView?.isHidden = animals.isEmpty
        collectionView?.reloadData()
    }
    
}

// MARK: - METHOD: CollectionView
// TODO: 커스텀 셀 삽입 예정
extension QuickInfoListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        animals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entity = animals[indexPath.item] // 코어 데이터에서 가져온 배열
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReceiptCell.identifier, for: indexPath) as! ReceiptCell
        
        // 등록 목록용 UI 모드
        cell.updateUIForType(type: .regist)

        // name
        let name = entity.name ?? "이름없음"

        // state: AnimalStatus -> StateUILabel.state 로 매핑
        let state = mapToReceiptState(entity.status)

        // location: 위경도 문자열로 간단히 표시
        let location = "(\(entity.latitude), \(entity.longitude))"

        // 현재 모델에 createdAt(등록일)이 없어서 임시로 Date() 사용
        // CoreData에 (Date) 속성 추가 예정
        let startTime = Date()

        // endTime: regist 모드에서는 숨겨지므로 nil
        let endTime: Date? = nil

        // amount: 시간당 가격(또는 원하는 값)
        let amount = Int(entity.pricePerHour)

        cell.updateUI(
            name: name,
            state: state,
            location: location,
            startTime: startTime,
            endTime: endTime,
            amount: amount
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let entity = animals[indexPath.item]          // CoreData에서 가져온 배열
        guard let id = entity.id else { return }      // 클릭한 데이터의 UUID 추출

        // 같은 CoreDataManager를 Detail VM에 주입해줌
        let vm = DetailViewModel(coreDataManager: coreDataManager)
        let detailVC = DetailViewController(viewModel: vm)
        detailVC.animalID = id

        // 네비게이션 push
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

//MARK: - METHOD: Compositional Layout
extension QuickInfoListViewController {
    private  func getSection() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(313), heightDimension: .estimated(196)))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .estimated(313), heightDimension: .estimated(196)), subitems: [item])
        
        
        let section = NSCollectionLayoutSection(group: group)
        let itemWidth: CGFloat = 338
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
    QuickInfoListViewController()
}
