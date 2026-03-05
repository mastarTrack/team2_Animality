//
//  MyPageViewModel.swift
//  Animality
//
//  Created by Hanjuheon on 3/5/26.
//

import Foundation

class MyPageViewModel: ViewModelProtocol {
    
    //MARK: - Model
    private(set) var userModel: UserModel
    
    //MARK: - Enum
    /// ViewModel의 상태 전달용 Enum
    enum State {
        case updateUI(user: UserModel)
        case none
    }
    
    /// View에서 발생한 이벤트 정의 Enum
    enum Action {
        case initialized
        case CancelUserModify
        case ApproveuserModify
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
        case .ApproveuserModify:
            //TODO: 한주헌 - User 정보 CoreData 저장 및 재수신 코드 추가
            break
        }
    }
    
    //MARK: - METHOD: Init
    init(userModel: UserModel) {
        self.userModel = userModel
    }
    
}


//MARK: - METHOD: To Action
extension MyPageViewModel {
    func initialized() {
        state = .updateUI(user: userModel)
    }
}

