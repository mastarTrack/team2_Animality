//
//  registrationViewController.swift
//  Animality
//
//  Created by 김주희 on 3/2/26.
//

import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - View, VM 인스턴스 생성
    private let registerView = RegisterView()
    private let registerViewModel = RegisterViewModel()
    
    
    // MARK: - View 세팅
    override func loadView() {
        self.view = registerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindingData()
        
        // 네비게이션바 타이틀 설정
        self.title = "등록하기"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    // MARK: - Binding
    
    private func bindingData() {
        
        // View → ViewModel
        registerView.onNameEntered = { [weak self] text in
            self?.registerViewModel.action?(.enterName(text ?? ""))
        }
        
        registerView.onCategorySelected = { [weak self] category in
            self?.registerViewModel.action?(.categorySelected(category))
        }
        
        registerView.onTypeSelected = { [weak self] type in
            self?.registerViewModel.action?(.typeSelected(type))
        }
        
        registerView.onSizeSelected = { [weak self] size in
            self?.registerViewModel.action?(.sizeSelected(size))
        }
        
        registerView.onPriceSelected = { [weak self] price in
            self?.registerViewModel.action?(.pricePerHour(price))
        }
        
        registerView.onFlightSelected = { [weak self] isSelected in
            self?.registerViewModel.action?(.flightCapability(isSelected))
        }
        
        registerView.onLocationSelected = { [weak self] lat, lon in
            self?.registerViewModel.action?(.locationSelected(lat, lon))
        }
        
        registerView.onRegisterTapped = { [weak self] in
            self?.registerViewModel.action?(.registerTapped)
        }
        
        // ViewModel → View
        registerViewModel.stateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.render(state)
            }
        }
        
        
    }
    // MARK: -- 상태에 따른 View 렌더링
    
    private func render(_ state: RegisterViewModel.State) {
        
        switch state {
            
        case .none:
            break
            
        case .validationChanged(let isEnabled):
            registerView.updateRegisterButton(isEnabled)
            
        case .showAlert(let message):
            // showErrorAlert(message: message)
            print(message)
            
        case .registerSuccess:
            registerView.showSuccess()
            self.navigationController?.popViewController(animated: true)
        }
    }
}

private extension RegisterViewController {
    func updateRegisterButton(_ isEnabled: Bool) {
        // 버튼 활성화 처리하기
    }
}
