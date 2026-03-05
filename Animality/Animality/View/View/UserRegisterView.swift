//
//  RegisterView.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//
import UIKit
import SnapKit
import Then

final class UserRegisterView: UIView {
    //MARK: Set Attributes
    // 아이디 입력
    private let idTextField = UITextField().then {
        $0.placeholder = "아이디를 입력하세요"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 14
        $0.addLeftPadding(12)
        
        $0.snp.makeConstraints {
            $0.height.equalTo(56)
        }
    }
    
    // 비밀번호 입력
    private let passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호를 입력하세요"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 14
        $0.addLeftPadding(12)
        $0.isSecureTextEntry = true // 값 가리기
        
        $0.snp.makeConstraints {
            $0.height.equalTo(56)
        }
    }
    
    // 이름 입력
    private let nameTextField = UITextField().then {
        $0.placeholder = "이름을 입력하세요"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 14
        $0.addLeftPadding(12)
        
        $0.snp.makeConstraints {
            $0.height.equalTo(56)
        }
    }
    
    // 이메일 입력
    private let emailTextField = UITextField().then {
        $0.placeholder = "이메일을 입력하세요"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 14
        $0.addLeftPadding(12)
        $0.keyboardType = .emailAddress
        
        $0.snp.makeConstraints {
            $0.height.equalTo(56)
        }
    }
    
    // 가입 버튼
    private let registerButton = UIButton(type: .system).then {
        $0.setTitle("가입하기", for: .normal)
        $0.backgroundColor = .systemGray4
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 14
        $0.isEnabled = false
    }
    
    //MARK: Binding Closure (View -> VC)
    var registerButtonTapped: ((String, String, String, String?) -> Void)?
    
    //MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setLayout()
        setButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: Set Layout
extension UserRegisterView {
    private func setLayout() {
        let idTitleLabel = makeTitleLabel(of: "아이디")
        let idStack = makeLabelStack(of: [idTitleLabel, idTextField])
        
        let passwordTitleLabel = makeTitleLabel(of: "비밀번호")
        let passwordStack = makeLabelStack(of: [passwordTitleLabel, passwordTextField])
        
        let nameTitleLabel = makeTitleLabel(of: "이름")
        let nameStack = makeLabelStack(of: [nameTitleLabel, nameTextField])
        
        let emailTitleLabel = makeTitleLabel(of: "이메일")
        let optionTitleLabel = UILabel().then {
            $0.text = "(선택)"
            $0.textColor = .lightGray
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textAlignment = .left
        }
        let emailTitleStack = UIStackView(arrangedSubviews: [emailTitleLabel, optionTitleLabel]).then {
            $0.axis = .horizontal
            $0.spacing = 5
            $0.alignment = .leading
            emailTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        }
        let emailStack = makeLabelStack(of: [emailTitleStack, emailTextField])
        
        [idStack, passwordStack, nameStack, emailStack, registerButton].forEach {
            addSubview($0)
        }
        
        idStack.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }
        
        passwordStack.snp.makeConstraints {
            $0.top.equalTo(idStack.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }
        
        nameStack.snp.makeConstraints {
            $0.top.equalTo(passwordStack.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }
        
        emailStack.snp.makeConstraints {
            $0.top.equalTo(nameStack.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }
        
        registerButton.snp.makeConstraints {
            $0.top.equalTo(emailStack.snp.bottom).offset(32)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(56)
        }
    }
    
    private func makeTitleLabel(of title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = .text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        
        return label
    }
    
    private func makeLabelStack(of views: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }
}

//MARK: Methods
extension UserRegisterView {
    private func setButtonAction() {
        let register = UIAction { [weak self] _ in
            let id = self?.idTextField.text ?? ""
            let password = self?.passwordTextField.text ?? ""
            let name = self?.nameTextField.text ?? ""
            let email = self?.emailTextField.text ?? ""
            
            self?.registerButtonTapped?(id, password, name, email)
        }
        
        registerButton.addAction(register, for: .touchUpInside)
    }
    
    func setDelegate(vc: UITextFieldDelegate) {
        idTextField.delegate = vc
        passwordTextField.delegate = vc
        nameTextField.delegate = vc
        emailTextField.delegate = vc
    }
    
    func setButtonStatus() {
        allSatisfyNotEmpty() ? enableButton() : disableButton()
    }
    
    private func enableButton() {
        registerButton.backgroundColor = .deepRose
        registerButton.setTitleColor(.text, for: .normal)
        registerButton.isEnabled = true
    }
    
    private func disableButton() {
        registerButton.backgroundColor = .systemGray4
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.isEnabled = false
    }
    
    private func allSatisfyNotEmpty() -> Bool {
        if let id = idTextField.text,
           let password = passwordTextField.text,
           let name = nameTextField.text,
           !id.isEmpty, !password.isEmpty, !name.isEmpty {
            // (이메일 제외) 모든 텍스트필드에 값이 있을 때
            return true
        } else {
            // (이메일 제외) 하나라도 텍스트 필드에 값이 없을 때
            return false
        }
    }
}
