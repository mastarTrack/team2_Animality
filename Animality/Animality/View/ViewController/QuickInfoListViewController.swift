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
    
    //MARK: - Closures
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

// MARK: - METHOD: CollectionView
// TODO: 커스텀 셀 삽입 예정
extension QuickInfoListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = 10
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReceiptCell.identifier, for: indexPath)
        return cell
    }
}

//MARK: - METHOD: Compositional Layout
extension QuickInfoListViewController {
    private func getSection() -> NSCollectionLayoutSection {
        
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
