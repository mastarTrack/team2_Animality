//
//  MyPageViewController.swift
//  Animality
//
//  Created by Hanjuheon on 3/3/26.
//

import UIKit
import SnapKit
import Then

class MyPageViewController: UIViewController {
    
    //MARK: - Properties
    private var isAnimating = false
    private var currentIndex: Int = 0

    //MARK: - ViewModel
    
    //MARK: - Components
    /// 이용내역 VC
    private let quickListVC = QuickInfoListViewController()
    /// 사용자정보 VC
    private let myPageInfoVC = MyPageInfoViewController()
    /// 상단 메뉴 세그먼트
    private let segmentedMenu = UISegmentedControl().then {
        /// 세그먼트 아이템 설정 수정
        $0.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.systemGray,
                .font: UIFont.boldSystemFont(ofSize: 14)
            ],
            for: .normal
        )
        $0.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.accentBlue,
                .font: UIFont.boldSystemFont(ofSize: 14)
            ],
            for: .selected
        )
        /// 세그먼트 아이템 추가
        $0.insertSegment(withTitle: "이용 내역", at: 0, animated: true)
        $0.insertSegment(withTitle: "사용자 정보", at: 1, animated: true)
        $0.selectedSegmentIndex = 0
    }
    /// 세그먼트값에 대한 VC 출력 컨테이너
    private let containerView = UIView()
    
    /// 현재 컨테이너에서 출력되고 있는 VC
    private var currentVC: UIViewController? = nil
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "나의 정보"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "로그아웃 🚪",
            primaryAction: UIAction {[weak self] _ in
                guard let self else { return }
                self.didTapLogout()
            }
        )
        configureUI()
        showSegmentToVC(nextVC: quickListVC, nextIndex: 0)
    }
}

//MARK: - METHOD: Logout
extension MyPageViewController {
    // 로그아웃 탭액션 메소드
    private func didTapLogout() {
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃을 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) {
            [weak self] _ in
            guard let self else { return }
            self.comfirmLogout()
        })
        present(alert, animated: true)
    }
    
    /// 로그아웃 동작 메소드
    //  TODO: 로그인페이지로 전환코드 추가 예정
    private func comfirmLogout() {
    }
}

//MARK: - METHOD: Segment
extension MyPageViewController {
    private func bindSegmentAction() {
        segmentedMenu.addAction(UIAction {
            [weak self] _ in
            guard let self else { return }
            let nextIndex = self.segmentedMenu.selectedSegmentIndex
            let nextVC = nextIndex == 0 ? self.quickListVC : self.myPageInfoVC
            self.showSegmentToVC(nextVC: nextVC, nextIndex: nextIndex)
        }, for: .valueChanged)
    }
    
    private func showSegmentToVC(nextVC: UIViewController, nextIndex: Int, animated: Bool = true) {
        
        /// 같음 뷰면 화면전환이 불필요하므로 리턴
        guard currentVC !== nextVC else { return }
        /// 변환 동작중에 함수가 실행되면 애니메이션 오류가 있을 수 있으니 리턴
        guard !isAnimating else { return }
        
        guard let oldVC = currentVC else {
            addChild(nextVC)
            containerView.addSubview(nextVC.view)
            nextVC.view.frame = containerView.bounds
            nextVC.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            nextVC.didMove(toParent: self)
            
            currentVC = nextVC
            currentIndex = nextIndex
            return
        }
        
        isAnimating = true
        segmentedMenu.isUserInteractionEnabled = false
        
        let width = containerView.bounds.width
        let goingRight = nextIndex > currentIndex
        let offset = width * (goingRight ? 1 : -1)
        
        addChild(nextVC)
        containerView.addSubview(nextVC.view)
        nextVC.view.frame = containerView.bounds.offsetBy(dx: offset, dy: 0)
        
        oldVC.willMove(toParent: nil)
        let duration: TimeInterval = animated ? 0.28 : 0

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            oldVC.view.frame = self.containerView.bounds.offsetBy(dx: -offset, dy: 0)
            nextVC.view.frame = self.containerView.bounds
        } completion: { [weak self] _ in
            guard let self else { return }
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParent()

            nextVC.didMove(toParent: self)

            self.currentVC = nextVC
            self.currentIndex = nextIndex

            self.isAnimating = false
            self.segmentedMenu.isUserInteractionEnabled = true
        }
    }
}


//MARK: - METHOD: Configure UI
extension MyPageViewController {
    private func configureUI() {
        bindSegmentAction()
        view.addSubview(segmentedMenu)
        view.addSubview(containerView)
        
        segmentedMenu.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(320)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(segmentedMenu.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.trailing.equalToSuperview().inset(10)
        }
    }
}

@available(iOS 17.0, *)
#Preview{
    MyPageViewController()
}
