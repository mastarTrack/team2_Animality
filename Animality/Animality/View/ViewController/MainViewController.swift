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
    
    // MARK: - Properites
    /// TabBar Item
    private lazy var tabItems: [TabItem] = {
        // 샘플/임시 유저 & VM (나중에 로그인 유저로 교체)
        let user = UserModel.sample
        let myPageVM = MyPageViewModel(userModel: user)
        
        return [
            TabItem(
                title: "지도 화면",
                imageName: "map",
                selectedImageName: "map.fill",
                makeViewController: {
                    let vc = MapViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    return nav
                }
            ),
            TabItem(
                title: "개체 등록",
                imageName: "plus.circle",
                selectedImageName: "plus.circle.fill",
                makeViewController: {
                    let vc = RegisterViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    return nav
                }
            ),
            TabItem(
                title: "마이 페이지",
                imageName: "person",
                selectedImageName: "person.fill",
                makeViewController: {
                    let vc = MyPageViewController(vm: myPageVM)
                    let nav = UINavigationController(rootViewController: vc)
                    return nav
                }
            )
        ]
    }()
    
    // MARK: - Viewmodel
    let animalityModelManager: AnimalityModelManager
    
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
    
    init(user: UserModel) {
        self.animalityModelManager = AnimalityModelManager(user: user, coreDataManager: CoreDataManager())
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
    let userModel = UserModel.sample
    MainViewController(user: userModel)
}
