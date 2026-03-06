//
//  LoginViewController.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//
import UIKit
import SnapKit

final class LoginViewController: UIViewController {
    let loginView = LoginView()
    let viewModel = LoginViewModel()
    
    var successLoginClosure: ((UserModel)->Void)?
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonAction()
        viewModelActionBinding()
        viewModel.action(.Init)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModelActionBinding()
    }
}

//MARK: - METHOD Viewmodel binding
extension LoginViewController {
    func viewModelActionBinding() {
        viewModel.stateChanged = { [weak self] state in
            print("viewModelActionBinding")
            
            
            guard let self else { print("no self"); return }
            
            switch state {
            case .failed(_):
                return
            case .none:
                return
            case .success:
                return
            case .resultLogin(let result):
                print("resultLogin")
                guard let result = result else {
                    let alert = UIAlertController(status: .deniLogin)
                    present(alert, animated: true)
                    return
                }
                successLoginClosure?(result)
            case .Init(let id, let pw):
                loginView.setLoginInfo(id: id, pw: pw)
            }
        }
    }
}

//MARK: - METHOD Button Binding
extension LoginViewController {
    private func setButtonAction() {
        let navToRegister = UIAction { [weak self] _ in
            guard let viewModel = self?.viewModel else { return }
            let vc = UserRegisterViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        let navToLogin = UIAction { [weak self] _ in
            guard let viewModel = self?.viewModel else { return }
            let loginInfo = self?.loginView.getloginInfo()
            viewModel.action(.checkLogin(loginInfo?.id ?? "", loginInfo?.pw ?? ""))
        }
        
        loginView.registerButton.addAction(navToRegister, for: .touchUpInside)
        loginView.loginButton.addAction(navToLogin, for: .touchUpInside)
    }
}

@available(iOS 17.0, *)
#Preview {
    let nav = UINavigationController(rootViewController: LoginViewController())
    return nav
}
