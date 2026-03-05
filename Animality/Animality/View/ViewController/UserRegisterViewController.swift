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
        super.init()
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
    }
    
    private func bindingData() {
        userRegisterView.registerButtonTapped = { [weak self] (id, password, name, email) in
            self?.viewModel.action(.register(id, password, name, email))
        }
    }
}

extension UserRegisterViewController {
    private func setDelegate() {
        userRegisterView.setDelegate(vc: self)
    }
    
    private func setButtonAction() {
        
    }
}

extension UserRegisterViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersInRanges ranges: [NSValue], replacementString string: String) -> Bool {
        userRegisterView.setButtonStatus()
        return true
    }
}
