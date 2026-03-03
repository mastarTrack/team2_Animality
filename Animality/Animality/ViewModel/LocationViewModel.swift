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
    }
    
    // 상태 열거형
    enum State {
        case none
        case initialized(lat: Double, lng: Double, markers: [(type: String, lat: Double, lng: Double)])
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
        case let .initialized(lat, lng):
            coordinates = categorizeAnimalByCoordinate() // 좌표 별로 동물 객체를 분류
            
            let markers = fetchMarkers(of: coordinates) // 생성할 마커 배열
            self.state = .initialized(lat: lat, lng: lng, markers: markers)
            
        case let .didUpdateLocations(lat, lng):
            self.state = .locationChanged(lat: lat, lng: lng)
        }
    }
    
    // 프로퍼티 선언
    let coreDataManager = TestCoreDataManager()

    private var coordinates = [Coordinate: [AnimalEntity]]() // 좌표별 동물 딕셔너리 [좌표: [동물]]
    
    // 좌표별 동물 분류 메서드
    private func categorizeAnimalByCoordinate() -> [Coordinate: [AnimalEntity]]{
        let animals = coreDataManager.fetchAllAnimalEntities()

        return animals.reduce(into: [Coordinate: [AnimalEntity]]()) { dic, animal in
            let point = Coordinate(latitude: animal.latitude, longitude: animal.longitude)
            dic[point, default: []].append(animal)
        }
    }
    
    // 마커를 생성할 좌표와 동물 타입을 반환하는 메서드 [(type: 동물 타입, lat: 위도, lng: 경도)]
    //TODO: 화면에 보이는 지도 범위 내의 마커들만 생성해도 되지 않을까? - VC에서 설정해야할 것 같긴 함
    private func fetchMarkers(of data: [Coordinate: [AnimalEntity]]) -> [(type: String, lat: Double, lng: Double)] {
        return data.reduce(into: [(type: String, lat: Double, lng: Double)]()) { arr, point in
            let types = point.value.compactMap { $0.type }.sorted()
            
            guard !types.isEmpty else { return }
            
            if types.count == 1 { // 동물 타입이 한가지일 경우
                arr.append((type: types.first!, lat: point.key.latitude, lng: point.key.longitude))
            } else {
                var typeCount = [String: Int]() // [동물 타입: 수]
                for t in types {
                    typeCount[t, default: 0] += 1
                    
                    // 가장 수가 많은 동물 타입 (동일할 경우 알파벳이 빠른 순서)
                    let type = typeCount.sorted(by: { $0.value > $1.value }).first!.key
                    arr.append((type: type, lat: point.key.latitude, lng: point.key.longitude))
                }
            }
        }
    }

}

struct Coordinate: Hashable {
    var latitude: Double
    var longitude: Double
}
