//
//  UserRegisterViewController.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//
import UIKit
import SnapKit
import Then

final class UserRegisterViewController: UIViewController {
    let userRegisterView = UserRegisterView()
    let viewModel: LoginViewModel
    
    //MARK: init
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: VC LifeCycle
    override func loadView() {
        view = userRegisterView
    }
    
    override func viewDidLoad() {
        self.title = "회원가입"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .semibold)]
        userRegisterView.setDelegate(vc: self)
        bindingData()
    }
    
    private func bindingData() {
        userRegisterView.registerButtonTapped = { [weak self] (id, password, name, email) in
            self?.viewModel.action(.register(id, password, name, email))
        }
        
        viewModel.stateChanged = { [weak self] state in
            switch state {
            case .none:
                break
            case .success:
                self?.successAction()
            case .failed(let message):
                self?.showAlert(title: "가입 실패", message: message)
            }
        }
    }
    
    private func successAction() {
        let message = "회원 가입이 완료되었습니다.\n로그인 후 서비스를 이용해주세요."
        
        let alert = UIAlertController(title: "환영합니다!", message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) { _ in
            self.dismiss(animated: true)
        }
        
        alert.addAction(confirm)
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(confirm)
        
        present(alert, animated: true)
    }
}


extension UserRegisterViewController: UITextFieldDelegate {
    // 텍스트 필드의 값이 바뀔때마다 등록하기 버튼 활성화 여부 설정
    func textField(_ textField: UITextField, shouldChangeCharactersInRanges ranges: [NSValue], replacementString string: String) -> Bool {
        userRegisterView.setButtonStatus()
        return true
    }
}
