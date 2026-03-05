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
    }
    
    // 비밀번호 입력
    private let passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호를 입력하세요"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 14
        $0.addLeftPadding(12)
    }
    
    // 이름 입력
    private let nameTextField = UITextField().then {
        $0.placeholder = "이름을 입력하세요"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 14
        $0.addLeftPadding(12)
    }
    
    // 이메일 입력
    private let emailTextField = UITextField().then {
        $0.placeholder = "이메일을 입력하세요"
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 14
        $0.addLeftPadding(12)
        $0.keyboardType = .emailAddress
    }
    
    // 등록 버튼
    private let registerButton = UIButton(type: .system).then {
        $0.setTitle("가입하기", for: .normal)
        $0.backgroundColor = .deepRose
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        $0.setTitleColor(.text, for: .normal)
        $0.layer.cornerRadius = 14
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
            $0.textColor = .systemGray4
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }
        let emailTitleStack = UIStackView(arrangedSubviews: [emailTitleLabel, optionTitleLabel]).then {
            $0.axis = .horizontal
            $0.spacing = 5
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
