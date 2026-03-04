//
//  MyPageInfoViewModel.swift
//  Animality
//
//  Created by Hanjuheon on 3/5/26.
//

import Foundation

class QuickInfoListViewModel: ViewModelProtocol {
    
    //MARK: - Model
    private var userModel: UserModel
    
    //MARK: - Enum
    /// ViewModel의 상태 전달용 Enum
    enum State {
        case updateUI(user: UserModel)
        case none
    }
    
    /// View에서 발생한 이벤트 정의 Enum
    enum Action {
        case initialized
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
        }
    }
    
    //MARK: - METHOD: Init
    init(userModel: UserModel) {
        self.userModel = userModel
    }
    
}


//MARK: - METHOD: To Action
extension QuickInfoListViewModel {
    func initialized() {
        state = .updateUI(user: userModel)
    }
}


