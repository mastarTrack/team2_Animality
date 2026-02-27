//
//  LocationViewModel.swift
//  Animality
//
//  Created by t2025-m0143 on 2/27/26.
//

import CoreLocation

class LocationViewModel: ViewModelProtocol {
    // 액션 열거형
    enum Action {
        case didUpdateLocations(lat: Double, lng: Double)
    }
    
    // 상태 열거형
    enum State {
        case none
        case locationChanged(lat: Double, lng: Double)
    }
    
    var state: State = .none {
        didSet {
            stateChanged?(state) // 상태가 변화할 때마다 동작
        }
    }
    
    var stateChanged: ((State) -> Void)? // 상태가 변화할 때 실행할 동작
    
    func action(_ action: Action) {
        switch action {
        case let .didUpdateLocations(lat, lng):
            self.state = .locationChanged(lat: lat, lng: lng)
        }
    }
    

}
