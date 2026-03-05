//
//  MyPageViewController.swift
//  Animality
//
//  Created by Hanjuheon on 3/2/26.
//

import UIKit
import Then
import SnapKit


class MyPageInfoViewController : UIViewController {
    
    //MARK: - ViewModel
    private var vm: MyPageViewModel
    
    //MARK: - Components
    /// 스크롤 뷰
    let scrollView = UIScrollView()
    
    /// ScrollView 배치용 뷰
    let contentView = UIView()
    
    /// 유저정보들을 쌓을 스택뷰
    let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 15
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    /// 유저 타이틀 이미지
    private let titleImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 40
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.systemGray6.cgColor
    }
    /// 유저 타이틀 아이디 라벨
    private let titleNameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textAlignment = .right
    }
    /// 유저 아이디 라벨
    private let idLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textAlignment = .right
    }
    /// 유저 이름 텍스트 필드
    private let nameField = UITextField().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textAlignment = .right
    }
    /// 유저 이메일 텍스트 필드
    private let emailField = UITextField().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textAlignment = .right
    }
    /// 유저 가입날짜 라벨
    private let registLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textAlignment = .right
    }
    /// 유저 렌탈 횟수 라벨
    private let rentCountLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textAlignment = .right
    }

    /// 사용자 정보 수정버튼
    private let modifyButton = UIButton().then {
        $0.setTitle("사용자 정보 수정", for: .normal)
        $0.setTitle("수정 완료", for: .selected)
        $0.backgroundColor = .white
        $0.setTitleColor(.systemGray, for: .normal)
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray.cgColor
    }

    /// 등록 내역 버튼
    private let rentRegistListButton = UIButton().then {
        $0.setTitle("등록 내역", for: .normal)
        $0.backgroundColor = .white
        $0.setTitleColor(.systemGray, for: .normal)
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray.cgColor
    }
    /// 수정 취소 버튼
    private let modifyCancelButton = UIButton().then {
        $0.setTitle("수정 취소", for: .normal)
        $0.backgroundColor = .white
        $0.setTitleColor(.systemGray, for: .normal)
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray.cgColor
        $0.isHidden = true
    }
    
    /// 편집 중인 텍스트 필드확인 택스트 필드
    private weak var activeField: UIView?
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "사용자 정보"
        bindingData()
        bindButtonAction()
        configureUI()
        vm.action(.initialized)
        setupKeyboardHandling()
    }
    
    init(vm: MyPageViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - METHOD: Binding VM Action
extension MyPageInfoViewController {
    // VM state 클로저 바인딩 메소드
    private func bindingData() {
        vm.stateChanged = { [weak self] state in
            guard let self else { return }
            
            switch state {
            case .none:
                break
            case .updateUI:
                updateUI(image: nil,
                         id: vm.modelManager.user.id,
                         name: vm.modelManager.user.name,
                         email: vm.modelManager.user.email,
                         registDate: vm.modelManager.user.registDate,
                         rentCount: vm.modelManager.user.rentalCount
                )
            }
        }
    }
}

//MARK: - METHOD: Button Action Binding
extension MyPageInfoViewController {
    func bindButtonAction() {
        modifyButton.addAction( UIAction { [weak self] _ in
            guard let self else { return }
            if self.modifyButton.isSelected {
                // 저장/종료 시점 콜백
                let alert = UIAlertController(title: "정보 수정 확인", message: "수정한 정보를 저장하시겠습니까?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "수정", style: .destructive) { _ in
                    self.modifyButton.isSelected.toggle()
                    self.setEditingMode(self.modifyButton.isSelected)
                    self.vm.action(.ApproveuserModify)
                })
                present(alert, animated: true)
            } else {
                self.modifyButton.isSelected.toggle()
                self.setEditingMode(self.modifyButton.isSelected)
            }
            
            }, for: .touchUpInside )
        
        modifyCancelButton.addAction( UIAction { [weak self] _ in
            guard let self else { return }
            self.setEditingMode(false)
            self.vm.action(.CancelUserModify)
        }, for: .touchUpInside )
        
        rentRegistListButton.addAction( UIAction { [weak self] _ in
            guard let self else { return }
            // TODO: 등록 목록 화면 전환 코드 추가 예정
            let quickListVC = QuickInfoListViewController(cellType: .regist, vm: vm)
            self.navigationController?.pushViewController(quickListVC, animated: true)
        }, for: .touchUpInside )
    }
}

//MARK: - METHOD: Update UI
extension MyPageInfoViewController {
    /// UI 업데이트 메소드
    func updateUI(image: UIImage?, id: String, name: String, email: String, registDate: Date, rentCount: Int) {
        titleImage.image = image ?? UIImage.pegasusPin
        titleNameLabel.text = name
        nameField.text = name
        idLabel.text = id
        emailField.text = email
        registLabel.text = registDate.formatted()
        rentCountLabel.text = String(rentCount)
    }
    
    /// 사용자 정보 수정 메소드
    private func setEditingMode(_ isEditing: Bool) {
        modifyButton.isSelected = isEditing

        [nameField, emailField].forEach { field in
            field.isUserInteractionEnabled = isEditing
            field.borderStyle = isEditing ? .roundedRect : .none
            field.backgroundColor = isEditing ? .secondarySystemBackground : .clear
        }

        modifyCancelButton.isHidden = !isEditing
        rentRegistListButton.isHidden = isEditing

        if !isEditing { view.endEditing(true) }
    }
}

//MARK: - METHOD: Keyboard
extension MyPageInfoViewController {

    private func setupKeyboardHandling() {
        // 어떤 필드가 활성인지 추적
        [nameField, emailField].forEach { field in
            field.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
            field.addTarget(self, action: #selector(editingDidEnd(_:)), for: .editingDidEnd)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        // 화면 탭하면 키보드 내리기(선택)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc
    private func editingDidBegin(_ sender: UITextField) {
        activeField = sender
    }
    
    @objc
    private func editingDidEnd(_ sender: UITextField) {
        if activeField === sender { activeField = nil }
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc
    private func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        // 키보드 프레임을 "내 view 기준"으로 변환
        let keyboardFrameInView = view.convert(endFrame, from: nil)

        // 내 view의 하단과 키보드 상단이 겹치는 만큼
        let overlap = max(0, view.bounds.maxY - keyboardFrameInView.minY)

        // 탭바가 있으면 그 높이만큼은 이미 가려져있을 수 있으니 보정
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0

        // bottomInset = 키보드 겹침 - 탭바높이(겹치는 만큼만)
        let bottomInset = max(0, overlap - tabBarHeight) + 12

        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.scrollView.contentInset.bottom = bottomInset
            self.scrollView.scrollIndicatorInsets.bottom = bottomInset
            self.view.layoutIfNeeded()
        }

        // ✅ 여기 핵심: contentView 좌표계로 변환해야 안정적
        guard let active = activeField else { return }
        DispatchQueue.main.async {
            let rectInContent = active.convert(active.bounds, to: self.contentView)
            self.scrollView.scrollRectToVisible(rectInContent.insetBy(dx: 0, dy: -24), animated: true)
        }
    }
}


//MARK: - MATHOD: Configure UI
extension MyPageInfoViewController {
    private func configureUI() {
        
        scrollView.keyboardDismissMode = .interactive
        scrollView.contentInsetAdjustmentBehavior = .never
        
        let titleView = UIView().then{
            $0.backgroundColor = .deepRose
            $0.layer.cornerRadius = 40
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.systemGray6.cgColor
        }
        titleView.addSubview(titleImage)
        titleView.addSubview(titleNameLabel)

        
        let ui = [idLabel, nameField, emailField, registLabel, rentCountLabel]
        
        let titleLabels = ["아이디", "이름", "이메일", "가입 날짜", "렌탈 횟수"].map{
            title -> UILabel in
            let label = UILabel().then {
                $0.text = title
                $0.font = .systemFont(ofSize: 14)
                $0.textColor = .systemGray
                $0.textAlignment = .left
            }
            return label
        }
        
        let stackViews = (0..<ui.count).map { _ -> UIStackView in
            let stackView = UIStackView().then {
                $0.backgroundColor = .systemGray6
                $0.axis = .horizontal
                $0.alignment = .center
                $0.layer.cornerRadius = 10
                $0.isLayoutMarginsRelativeArrangement = true
                $0.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            }
            return stackView
        }
        
        stackView.addArrangedSubview(titleView)
        for i in 0..<ui.count {
            stackViews[i].addArrangedSubview(titleLabels[i])
            stackViews[i].addArrangedSubview(ui[i])
            stackView.addArrangedSubview(stackViews[i])
        }
        
        stackView.addArrangedSubview(modifyButton)
        stackView.addArrangedSubview(rentRegistListButton)
        stackView.addArrangedSubview(modifyCancelButton)
        
        contentView.addSubview(stackView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        titleView.snp.makeConstraints {
            $0.height.equalTo(180)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        titleImage.snp.makeConstraints {
            $0.height.width.equalTo(80)
            $0.top.equalToSuperview().offset(35)
            $0.centerX.equalToSuperview()
        }
        titleNameLabel.snp.makeConstraints {
            $0.top.equalTo(titleImage.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        
        for stack in 0..<stackViews.count {
            stackViews[stack].snp.makeConstraints{
                $0.height.equalTo(50)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
        }
        
        [modifyButton, rentRegistListButton, modifyCancelButton].forEach{
            $0.snp.makeConstraints {
                $0.height.equalTo(50)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    let model = AnimalityModelManager(user: UserModel.sample, coreDataManager: CoreDataManager())
    let vm = MyPageViewModel(modelManager: model)
    let vc = MyPageInfoViewController(vm: vm)
    return vc
}
