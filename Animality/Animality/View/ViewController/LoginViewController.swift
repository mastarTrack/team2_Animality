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
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonAction()
    }
    
}

extension LoginViewController {
    private func setButtonAction() {
        let navToRegister = UIAction { [weak self] _ in
            guard let viewModel = self?.viewModel else { return }
            let vc = UserRegisterViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        loginView.registerButton.addAction(navToRegister, for: .touchUpInside)
    }
}
