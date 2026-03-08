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
    private let registerViewModel: RegisterViewModel
    
    
    // modelManager를 받아서 ViewModel 생성
    init(modelManager: AnimalityModelManager) {
        self.registerViewModel = RegisterViewModel(modelManager: modelManager)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    
    // MARK: - LifeCycle
    override func loadView() {
        self.view = registerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션바 타이틀 설정
        self.title = "등록하기"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        bindView()
        bindViewModel()
    }
}


    // MARK: - Binding
extension RegisterViewController {
    
    // View → ViewModel
    private func bindView() {
        
        registerView.onNameEntered = { [weak self] text in
            self?.registerViewModel.action(.enterName(text ?? ""))
        }
        
        registerView.onTypeSelected = { [weak self] type in
            self?.registerViewModel.action(.typeSelected(type))
        }
        
        registerView.onSizeSelected = { [weak self] size in
            self?.registerViewModel.action(.sizeSelected(size))
        }
        
        registerView.onFlightSelected = { [weak self] flight in
            self?.registerViewModel.action(.flightCapabilitySelected(flight))
        }
        
        registerView.onPriceEntered = { [weak self] price in
            self?.registerViewModel.action(.pricePerHour(price ?? ""))
        }
        
        registerView.onPickedCoordinate = { [weak self] Coordinate in
            self?.registerViewModel.action(.locationSelected(Coordinate.latitude, Coordinate.longitude))
        }
        
        registerView.onRegisterTapped = { [weak self] in
            self?.askRegister()
        }
    }
    
    // ViewModel → View
    private func bindViewModel() {
        registerViewModel.stateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.render(state)
            }
        }
    }
}
    
// MARK: -- 상태에 따른 View 렌더링
extension RegisterViewController {
    
    private func render(_ state: RegisterViewModel.State) {
        
        switch state {
            
        case .none:
            break
            
        case .validationChanged(let isEnabled):
            registerView.updateRegisterButton(isEnabled)
            
        case .showAlert(let message):
            showAlert(message)
            
        case .registerSuccess:
            handelRegisterSuccess()
        }
    }
}

extension RegisterViewController {
    
    private func askRegister() {
        
        let askRegister = UIAlertController(title: "등록 진행", message: "새로운 동물을 등록할까요?", preferredStyle: .alert)
        
        askRegister.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.registerViewModel.action(.registerTapped)
        })
        askRegister.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        
        self.present(askRegister, animated: true)
    }
    
    private func handelRegisterSuccess() {
        refreshMap() // Map reset
        
        // 등록 뷰 리셋
        registerView.resetSelection()
        showAlert("동물 등록에 성공했습니다.")
        self.navigationController?.popViewController(animated: true) // 저장 성공시 이전 화면으로 이동하기
        
    }

    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func refreshMap() {
        //mapVC 호출 - 마커 refresh
        guard let nav = self.tabBarController?.viewControllers?.first as? UINavigationController else { return }
        guard let mapVC = nav.viewControllers.first as? MapViewController else { return }
        mapVC.newRegister()
    }
}
