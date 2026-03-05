//
//  LoginViewController.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//
import UIKit
import SnapKit

final class LoginViewController: UIViewController {
    private let loginView = LoginView()
    private let viewModel: LoginViewModel
    
    //MARK: 이니셜라이저에서 뷰모델 주입받음
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindingData()
    }
    
    //MARK: 여기서 LoginView 클로저 정의
    private func bindingData() {
        loginView.registerButtonPushed = { [weak self] in
            guard let viewModel = self?.viewModel else { return }
            let vc = UserRegisterViewController(viewModel: viewModel) // 뷰모델 넘겨주면서 push
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension LoginViewController {

}
