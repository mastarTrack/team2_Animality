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
    
    override func loadView() {
        view = userRegisterView
    }
    
    override func viewDidLoad() {
        self.title = "회원가입"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .semibold)]
    }
}
