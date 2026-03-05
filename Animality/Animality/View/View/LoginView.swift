//
//  LoginView.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//

import UIKit
import Then
import SnapKit

final class LoginView: UIView {
    //MARK: Set Attributes
    // ID 텍스트필드
    private let idTextField = UITextField().then {
        $0.placeholder = "ID or Email"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 16
        $0.font = .systemFont(ofSize: 17, weight: .medium)
        $0.addLeftPadding(12)
    }
    
    // 비밀번호 텍스트필드
    private let passwordTextField = UITextField().then {
        $0.placeholder = "Password"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 16
        $0.font = .systemFont(ofSize: 17, weight: .medium)
        $0.addLeftPadding(12)
    }
    
    // 로그인 버튼
    let loginButton = UIButton(type: .system).then {
        $0.setTitle("로그인", for: .normal)
        $0.backgroundColor = .coralText
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(.text, for: .normal)
        $0.layer.cornerRadius = 25
    }
    
    // 회원가입 버튼
    let registerButton = UIButton().then {
        $0.setTitle("회원가입", for: .normal)
        $0.backgroundColor = .white
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(.text, for: .normal)
        $0.layer.cornerRadius = 25
        $0.layer.borderColor = UIColor.rose.cgColor
        $0.layer.borderWidth = 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoginView {
    private func setLayout() {
        let titleLabel = UILabel().then {
            if let font = UIFont(name: "Bungee-Regular", size: 48) {
                $0.attributedText = NSAttributedString(string: "Animality", attributes: [.font: font])
            }
            $0.textAlignment = .center
        }
        
        let imageView = UIImageView().then {
            $0.image = .logo
            $0.contentMode = .scaleAspectFit
        }
        
        [titleLabel, imageView, idTextField, passwordTextField, loginButton, registerButton].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.width.height.equalTo(183)
        }
        
        idTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(50)
            $0.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(idTextField.snp.bottom).offset(8)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(50)
            $0.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(passwordTextField.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(40)
            $0.height.equalTo(50)
        }
        
        registerButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(loginButton.snp.bottom).offset(8)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(40)
            $0.height.equalTo(50)
        }
    }
    
    func setDelegate(vc: UITextFieldDelegate) {
        idTextField.delegate = vc
        passwordTextField.delegate = vc
    }
    
    func getloginInfo() -> (id: String,pw: String) {
        return ( idTextField.text ?? "" , passwordTextField.text ?? "")
    }
}
