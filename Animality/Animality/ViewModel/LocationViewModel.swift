//
//  LocationViewModel.swift
//  Animality
//
//  Created by t2025-m0143 on 2/27/26.
//

import Foundation
import CoreLocation

class LocationViewModel: ViewModelProtocol {
    // 액션 열거형
    enum Action {
        case didUpdateLocations(lat: Double, lng: Double)
        case fetchMarkers
    }
    
    // 상태 열거형
    enum State {
        case none
        case locationChanged(lat: Double, lng: Double)
        case fetchMarkers([(type: String, lat: Double, lng: Double)])
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
        case .fetchMarkers:
            let targets = fetchMarkers()
            self.state = .fetchMarkers(targets)
        }
    }

    
    // 프로퍼티 선언
    let coreDataManager = TestCoreDataManager()
    
    private func fetchMarkers() -> [(type: String, lat: Double, lng: Double)] {
        let animals = coreDataManager.fetchAllAnimalEntities()
        return animals.reduce(into: [(type: String, lat: Double, lng: Double)]()) {
            guard let type = $1.type else { return }
            $0.append((type: type, lat: $1.latitude, lng: $1.longitude))
        }
    }

}
