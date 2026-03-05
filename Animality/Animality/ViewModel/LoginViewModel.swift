//
//  LoginViewModel.swift
//  Animality
//
//  Created by t2025-m0143 on 3/5/26.
//
import Foundation

final class LoginViewModel: ViewModelProtocol {
    enum Action {
        case register(String, String, String, String?)
    }
    
    enum State {
        case none
        case success
        case failed(String)
    }
    
    var state: State = .none {
        didSet {
            stateChanged?(state) // 상태가 변화할 때마다 동작
        }
    }
    var stateChanged: ((State) -> Void)? // 상태가 변화할 때 실행할 동작
    
    func action(_ action: Action) -> Void {
        switch action {
        case let .register(id, password, name, email):
            if !(email ?? "").isEmpty, !validateEmailExpression(email ?? "") { // 이메일 값이 있지만 유효하지 않을 때
                self.state = .failed("유효한 이메일 형식이 아닙니다.")
            } else {
                saveUserInfo(id: id, password: password, name: name, email: email)
                self.state = .success // 성공
            }
        }
    }
}

extension LoginViewModel {
    private func saveUserInfo(id: String, password: String, name: String, email: String?) {
        UserDefaults.standard.set(id, forKey: UserDefaultsKey.id.rawValue)
        UserDefaults.standard.set(password, forKey: UserDefaultsKey.id.rawValue)
        UserDefaults.standard.set(name, forKey: UserDefaultsKey.id.rawValue)
        UserDefaults.standard.set(email ?? "", forKey: UserDefaultsKey.id.rawValue)
    }
    
    private func validateEmailExpression(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let validation = NSPredicate(format: "SELF MATCHES %@", regex)
        return validation.evaluate(with: email)
    }
}
