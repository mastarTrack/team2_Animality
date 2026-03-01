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
        case initialized(lat: Double, lng: Double)
        case didUpdateLocations(lat: Double, lng: Double)
//        case fetchMarkers
    }
    
    // 상태 열거형
    enum State {
        case none
        case initialized(lat: Double, lng: Double, markers: [(type: String, lat: Double, lng: Double)])
        case locationChanged(lat: Double, lng: Double)
//        case fetchMarkers([(type: String, lat: Double, lng: Double)])
    }
    
    var state: State = .none {
        didSet {
            stateChanged?(state) // 상태가 변화할 때마다 동작
        }
    }
    var stateChanged: ((State) -> Void)? // 상태가 변화할 때 실행할 동작
    
    func action(_ action: Action) {
        switch action {
        case let .initialized(lat, lng):
            coordinates = categorizeAnimalByCoordinate()
            let markers = fetchMarkers()
            self.state = .initialized(lat: lat, lng: lng, markers: markers)
            
        case let .didUpdateLocations(lat, lng):
            self.state = .locationChanged(lat: lat, lng: lng)
            
//        case .fetchMarkers:
//            let markers = fetchMarkers()
//            self.state = .fetchMarkers(markers)
        }
    }

    
    // 프로퍼티 선언
    let coreDataManager = TestCoreDataManager()
    
//    private var animals = [AnimalEntity]() // 동물 배열
    private var coordinates = [Coordinate: [AnimalEntity]]() // 좌표별 동물 딕셔너리 [좌표: [동물]]
    
    private func categorizeAnimalByCoordinate() -> [Coordinate: [AnimalEntity]]{
        let animals = coreDataManager.fetchAllAnimalEntities()

        return animals.reduce(into: [Coordinate: [AnimalEntity]]()) { dic, animal in
            let point = Coordinate(latitude: animal.latitude, longtitude: animal.longitude)
            dic[point, default: []].append(animal)
        }
    }
    
    private func fetchMarkers() -> [(type: String, lat: Double, lng: Double)] {
        return coordinates.reduce(into: [(type: String, lat: Double, lng: Double)]()) { arr, point in
            let types = point.value.compactMap { $0.type }.sorted()
            
            guard !types.isEmpty else { return }
            
            if types.count == 1 {
                arr.append((type: types.first!, lat: point.key.latitude, lng: point.key.longtitude))
            } else {
                var typeCount = [String: Int]()
                for t in types {
                    typeCount[t, default: 0] += 1
                    let type = typeCount.sorted(by: { $0.value > $1.value }).first!.key
                    arr.append((type: type, lat: point.key.latitude, lng: point.key.longtitude))
                }
            }
        }
    }

}

struct Coordinate: Hashable {
    var latitude: Double
    var longtitude: Double
}
