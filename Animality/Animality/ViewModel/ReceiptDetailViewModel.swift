//
//  ReceiptD.swift
//  Animality
//
//  Created by Hanjuheon on 3/4/26.
//

import Foundation
import NMapsMap

/// 결제 내역 상세화면 ViewModel
class ReceiptDetailViewModel: ViewModelProtocol {
    //MARK: - Model
    
    //MARK: - Enum
    /// ViewModel의 상태 전달용 Enum
    enum State {
        case updateUI(data: RentReceipt)
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
            self.Init()
        }
    }
}

//MARK: - METHOD: To Action
extension ReceiptDetailViewModel {
    func Init() {
        state = .updateUI(data: RentReceipt.sample)
    }
}



