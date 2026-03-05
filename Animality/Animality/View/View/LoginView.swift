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
        $0.backgroundColor = .systemGray4
        $0.layer.cornerRadius = 16
    }
    
    // 비밀번호 텍스트필드
    private let passwordTextField = UITextField().then {
        $0.placeholder = "Password"
        $0.backgroundColor = .systemGray4
        $0.layer.cornerRadius = 16
    }
    
    // 로그인 버튼
    private let loginButton = UIButton(type: .system).then {
        $0.setTitle("로그인", for: .normal)
        $0.backgroundColor = .coralText
        $0.titleLabel?.font = .systemFont(ofSize: 18)
        $0.setTitleColor(.text, for: .normal)
        $0.layer.cornerRadius = 20
        $0.isEnabled = false
    }
    
    // 회원가입 버튼
    private let registerButton = UIButton(type: .system).then {
        $0.setTitle("로그인", for: .normal)
        $0.backgroundColor = .white
        $0.titleLabel?.font = .systemFont(ofSize: 18)
        $0.setTitleColor(.text, for: .normal)
        $0.layer.cornerRadius = 20
        $0.layer.borderColor = UIColor.rose.cgColor
        $0.layer.borderWidth = 2
        $0.isEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoginView {
    func setLayout() {
        let imageView = UIImageView().then {
            $0.image = .dogPin
            $0.contentMode = .scaleAspectFit
        }
        
        [imageView, idTextField, passwordTextField, loginButton, registerButton].forEach {
            addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.width.height.equalTo(183)
        }
        
        idTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(20)
        }
        
//        passwordTextField.snp.makeConstraints {
//            $0.centerX.
//        }
        
        
    }
}
