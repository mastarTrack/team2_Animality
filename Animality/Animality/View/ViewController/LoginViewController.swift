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
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "로그인 / 회원가입"
    }
}
