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

        setTitle()
    }
    
    private func setTitle() {
        self.title = "Animality"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.largeTitleTextAttributes = [.font: UIFont(name: "Bungee-Regular", size: 48)]

    }
}
