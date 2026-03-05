//
//  LoginViewModel.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//

final class LoginViewModel: ViewModelProtocol {
    enum Action {
        case register(String?, String?, String?, String?)
    }
    
    enum State {
        case none
    }
    
    var state: State = .none {
        didSet {
            stateChanged?(state) // 상태가 변화할 때마다 동작
        }
    }
    var stateChanged: ((State) -> Void)? // 상태가 변화할 때 실행할 동작
    
    func action(_ action: Action) -> Void {
        switch action {
        case let .register((id, password, name, email)):
            
        }
    }
}

extension LoginViewModel {
    private func validateInput(id: String?, password: String?, name: String?, email: String?) -> Bool {
        
        
    }
}
