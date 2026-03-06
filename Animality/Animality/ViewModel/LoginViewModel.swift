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
        case checkLogin(String, String)
        case Init
    }
    
    enum State {
        case none
        case success
        case failed(String)
        case resultLogin(UserModel?)
        case Init(String?, String?)
    }
    
    var state: State = .none {
        didSet {
            print("state changed \(state)")
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
        case let .checkLogin(id, pw):
            let result = checkLogin(id: id, pw: pw)
            self.state = .resultLogin(result)
            
        case let .Init:
            let userInfo = configureLogin()
            self.state = .Init(userInfo.id,userInfo.pw)
        }
    }
}

// MARK: - METHOD: Login
extension LoginViewModel {
    private func configureLogin()->(id:String?,pw: String?){
        let checkId = UserDefaults.standard.string(forKey: UserDefaultsKey.id.rawValue)
        let checkPw = UserDefaults.standard.string(forKey: UserDefaultsKey.password.rawValue)
        return (checkId, checkPw)
    }
    
    private func checkLogin(id: String, pw: String) -> UserModel? {
        let checkId = UserDefaults.standard.string(forKey: UserDefaultsKey.id.rawValue)
        let checkPw = UserDefaults.standard.string(forKey: UserDefaultsKey.password.rawValue)
        
        if id == checkId && pw == checkPw  {
            guard let uid = UserDefaults.standard.string(forKey: UserDefaultsKey.uid.rawValue),
            let name = UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue),
            let email = UserDefaults.standard.string(forKey: UserDefaultsKey.email.rawValue),
            let registDate = UserDefaults.standard.value(forKey: UserDefaultsKey.registDate.rawValue) as? Date else
            { return nil }
            let user = UserModel(uid: UUID(uuidString: uid)!, id: id, name: name, email: email, registDate: registDate, rentalCount: 0)
            return user
        } else {
            return nil
        }
    }
}

// MARK: - METHOD: Regist
extension LoginViewModel {
    private func saveUserInfo(id: String, password: String, name: String, email: String?) {
        UserDefaults.standard.set(id, forKey: UserDefaultsKey.id.rawValue)
        UserDefaults.standard.set(password, forKey: UserDefaultsKey.password.rawValue)
        UserDefaults.standard.set(name, forKey: UserDefaultsKey.name.rawValue)
        UserDefaults.standard.set(email ?? "" , forKey: UserDefaultsKey.email.rawValue)
        UserDefaults.standard.set(Date() , forKey: UserDefaultsKey.registDate.rawValue)

    }
    
    private func validateEmailExpression(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let validation = NSPredicate(format: "SELF MATCHES %@", regex)
        return validation.evaluate(with: email)
    }
}

