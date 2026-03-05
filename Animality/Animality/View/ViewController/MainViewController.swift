//
//  MainViewController.swift
//  Animality
//
//  Created by Hanjuheon on 2/27/26.
//

import UIKit
import SnapKit
import Then

/// 메인 화면 ViewController
class MainViewController: UITabBarController {

    //MARK: - ViewModel
    let modelManager: AnimalityModelManager
    
    // MARK: - INIT
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .coralText
        configureUI()
    }
    
    init(userModel: UserModel) {
        modelManager = AnimalityModelManager(user: userModel, coreDataManager: CoreDataManager())
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - METHOD: TAB BAR METHOD
extension MainViewController {
    /// 탭바 설정 메소드
    private func configureTabBar(tabitems: [TabItem]){
        let controllers = tabitems.map { item -> UIViewController in
            let vc = item.makeViewController()
            vc.tabBarItem = UITabBarItem(
                title: item.title,
                image: UIImage(systemName: item.imageName),
                selectedImage: UIImage(systemName: item.selectedImageName ?? item.imageName)
            )
            return vc
        }
        setViewControllers(controllers, animated: true)
    }
}

//MARK: - METHOD: Configure UI
extension MainViewController {
    /// 매인 UI 초기 설정 메소드
    private func configureUI() {
        let manager = modelManager

        let tabItems: [TabItem] = [
            TabItem(
                title: "지도 화면",
                imageName: "map",
                selectedImageName: "map.fill",
                makeViewController: { MapViewController() }
            ),
            TabItem(
                title: "등록 하기",
                imageName: "plus.circle",
                selectedImageName: "plus.circle.fill",
                makeViewController: { RegisterViewController() }
            ),
            TabItem(
                title: "마이페이지",
                imageName: "person",
                selectedImageName: "person.fill",
                makeViewController: { MyPageViewController(modelManager: manager) }
            )
        ]
        
        configureTabBar(tabitems: tabItems)
    }
}

@available(iOS 17.0, *)
#Preview {
    
    MainViewController(userModel: UserModel.sample)
}
