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
    // MARK: - Mockup Data
    /// 임시 탭바에 넣은 탭바아이템 목업 데이터
    private lazy var tabItems: [TabItem] = {
        // 샘플/임시 유저 & VM (나중에 로그인 유저로 교체)
        let user = UserModel.sample
        let myPageVM = MyPageViewModel(userModel: user)

        return [
            TabItem(
                title: "Map",
                imageName: "map",
                selectedImageName: "map.fill",
                makeViewController: { MapViewController() }
            ),
            TabItem(
                title: "Register",
                imageName: "plus.circle",
                selectedImageName: "plus.circle.fill",
                makeViewController: { RegisterViewController() }
            ),
            TabItem(
                title: "My Page",
                imageName: "person",
                selectedImageName: "person.fill",
                makeViewController: { MyPageViewController(vm: myPageVM) }
            )
        ]
    }()
    
    // MARK: - Viewmodel
    
    
    // MARK: - Components
    
    
    // MARK: - INIT
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        tabBar.tintColor = .coralText
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
        configureTabBar(tabitems: tabItems)
    }
}




@available(iOS 17.0, *)
#Preview {
    MainViewController()
}
