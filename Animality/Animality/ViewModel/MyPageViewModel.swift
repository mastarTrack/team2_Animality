//
//  MyPageViewModel.swift
//  Animality
//
//  Created by Hanjuheon on 3/5/26.
//

import Foundation

/// 마이페이지 ViewModel
class MyPageViewModel: ViewModelProtocol {
    
    //MARK: - Model
    private(set) var modelManager: AnimalityModelManager
        
    //MARK: - Enum
    /// ViewModel의 상태 전달용 Enum
    enum State {
        case updateUI
        case none
    }
    
    /// View에서 발생한 이벤트 정의 Enum
    enum Action {
        case initialized
        case CancelUserModify
        case ApproveuserModify(name:String,email: String)
        case fetchRegistAnimal
        case fetchReceipt
    }
    
    //MARK: - Properties
    /// View의 상태전달용 State
    var state: State = .none {
        didSet {
            stateChanged?(state)
        }
    }
    
    //MARK: - CLosures
    /// 상태전달용 클로져
    var stateChanged: ((State)->Void)?
    
    //MARK: - METHOD: Check ViewAction
    // View에서 전달받은 Action 처리 메소드
    func action(_ action: Action) {
        switch action {
        case .initialized:
            self.initialized()
        case .CancelUserModify:
            self.initialized()
        case .ApproveuserModify(let name, let email):
            modifyUserData(name: name, email: email)
        case .fetchRegistAnimal:
            return
        case .fetchReceipt:
            return
        }
    }
    
    //MARK: - METHOD: Init
    init(modelManager: AnimalityModelManager) {
        self.modelManager = modelManager
    }
}
 
//MARK: - METHOD: To Action
extension MyPageViewModel {
    // 초기 업데이트 메소드
    private func initialized() {
        state = .updateUI
    }
    // 유저가 등록한 동물 업데이트 메소드
    private func fetchRegistAnimal() {
        modelManager.refreashUserRegistAnimals()
        state = .updateUI
    }
    // 유저 영수증 업데이트 메소드
    private func fetchReceipt(){
        modelManager.refreshReceipts()
        state = .updateUI
    }
    // 유저 정보수정 메소드
    private func modifyUserData(name: String, email: String) {
        modelManager.updateUser(name: name, email: email)
        state = .updateUI
    }
}

