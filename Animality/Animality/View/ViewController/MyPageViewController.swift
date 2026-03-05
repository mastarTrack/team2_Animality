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
    private let vm: MyPageViewModel
    
    //MARK: - Components
    /// 이용내역 VC
    private var quickListVC: QuickInfoListViewController
    /// 사용자정보 VC
    private var myPageInfoVC: MyPageInfoViewController
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
    
    init(vm: MyPageViewModel) {
        self.vm = vm
        quickListVC = QuickInfoListViewController(cellType: .receipt, vm: vm)
        myPageInfoVC = MyPageInfoViewController(vm: vm)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    /*
     # addSubview + isHidden vs addChild()
     두 방식의 가장 큰 차이는 ViewController 계층 구조 형성 여부
     
     addChild()를 사용하여 ViewController를 추가하는 경우, 부모-자식 관계가 명확하게 형성되며 라이프사이클 메서드가 정상적으로 전파. 또한 시스템 이벤트(회전, SafeArea 변경, Trait 변화 등)도 자식 ViewController에 전달되어 보다 안정적인 구조를 만들 수 있다.
     
     반면 addSubview()만 사용하는 경우에는 단순히 View만 화면에 추가되는 것이며, ViewController 간의 계층 관계는 형성되지 않음. 즉 부모의 라이플 사이클이 동작한다고해서 내부에 선언된 ViewController도 같이 라이플 사이클이 동작한다는 것이 아니다.
     
     # 상시 오토레이아웃 설정이 동반되므로 메모리 이슈가 생길수 있을것 같다. 튜터님 도움 필요.
     */
    
    /// Segment Value에 따른 View 변환 베소드
    private func showSegmentToVC(nextVC: UIViewController, nextIndex: Int, animated: Bool = true) {
        
        /// 같음 뷰면 화면전환이 불필요하므로 리턴
        guard currentVC !== nextVC else { return }
        /// 변환 동작중에 함수가 실행되면 애니메이션 오류가 있을 수 있으니 리턴
        guard !isAnimating else { return }
        
        /// 현재 보여지고있는 VC 존재 여부 파악
        guard let oldVC = currentVC else {
            // 현재 아무것도 없는 상태(첫 설정)시 로직
            // 변경할 VC를 현재 VC의 자식으로 연결
            addChild(nextVC)
            // 자식 VC의 뷰를 화면에 설정
            containerView.addSubview(nextVC.view)
            // 자식 VC 뷰 프레임을 containerView 사이즈에 맞게 설정
            nextVC.view.frame = containerView.bounds
            // 뷰의 자동리사이즈 설정: flexible = 부모크기 만큼 크기가 리사이즈 됨
            nextVC.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            // 자식뷰의 설정 완료 알림
            nextVC.didMove(toParent: self)
            
            currentVC = nextVC
            currentIndex = nextIndex
            return
        }
        
        // 뷰 전환 체크(Lock)
        isAnimating = true
        segmentedMenu.isUserInteractionEnabled = false
        
        // 뷰 컨테이너 사이즈 체크
        let width = containerView.bounds.width
        // 인덱스값을 통한 좌우 슬라이드 결정
        let goingRight = nextIndex > currentIndex
        // 왼쪽으로 움직여야할시 음수값으로 이동해야하므로 -1 곱함
        let offset = width * (goingRight ? 1 : -1)
        
        // 변경할 VC를 현재 VC의 자식으로 연결
        addChild(nextVC)
        // 자식 VC의 뷰를 화면에 설정
        containerView.addSubview(nextVC.view)
        // 뷰 설정 및 배치 -> 안보인 곳에 배치 후 애니메이션을 통해 현재 화면을 넣기
        nextVC.view.frame = containerView.bounds.offsetBy(dx: offset, dy: 0)
        
        // 이전 뷰 해제 예약
        oldVC.willMove(toParent: nil)
        // 애니메이션 시간 설정
        let duration: TimeInterval = animated ? 0.28 : 0

        // 애니메이션 시작
        UIView.animate(
            withDuration: duration // 애니메이션 속도
            , delay: 0 // 딜레이 시간 설정: 0(바로 시작)
            , options: .curveEaseOut) //처음은 빠르게, 끝에 천천히
        {
            // 이전 VC 뷰 위치 변경: 애니메이션으로 진행하기에 스무스하게 이동하는 효과를 받음
            oldVC.view.frame = self.containerView.bounds.offsetBy(dx: -offset, dy: 0)
            // 변경 VC 뷰 위치 변경
            nextVC.view.frame = self.containerView.bounds
        } completion: { [weak self] _ in // 애니메이션 종료 후 코드 진행
            guard let self else { return }
            // 이전 VC의 뷰를 삭제
            oldVC.view.removeFromSuperview()
            // 이전 VC를 자식항목에서 제거
            oldVC.removeFromParent()
            // 변경뷰 설정 완료 알림
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
    let vm = MyPageViewModel(userModel: UserModel.sample)
    MyPageViewController(vm: vm)
}
