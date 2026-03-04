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
        case search(text: String)
    }
    
    // 상태 열거형
    enum State {
        case none
        case initialized(lat: Double, lng: Double, markers: [(type: AnimalType, coordinate: Coordinate)]) // (현재 위도, 현재 경도, 마커)
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
            
        case let .search(text):
            
        }
    }
    
    // 프로퍼티 선언
    let coreDataManager = CoreDataManager()
    let networkManager = NetworkManager()

    private var coordinates = [Coordinate: [Animal]]() // 좌표별 동물 딕셔너리 [좌표: [동물]]
    
    // AnimalEntity -> Animal
    private func fetchAllAnimals() -> [Animal] {
        let animalEntities = coreDataManager.fetchAllAnimalEntities()
        
        return animalEntities.reduce(into: [Animal]()) {
            guard let id = $1.id,
                  let name = $1.name,
                  let type = AnimalType(rawValue: $1.type ?? ""),
                  let status = AnimalStatus(rawValue: $1.status),
                  let size = AnimalSize(rawValue: $1.size ?? ""),
                  let flightCapability = FlightCapability(rawValue: $1.flightCapability ?? "") else { return }
            
            let animal = Animal(
                id: id,
                name: name,
                type: type,
                status: status,
                pricePerHour: Int($1.pricePerHour),
                currentLocation: Coordinate(latitude: $1.latitude, longitude: $1.longitude),
                size: size,
                flightCapability: flightCapability
            )
            
            $0.append(animal)
        }
    }
    
    // 좌표별 동물 분류 메서드
    private func categorizeAnimalByCoordinate() -> [Coordinate: [Animal]]{
        let animals = fetchAllAnimals()

        return animals.reduce(into: [Coordinate: [Animal]]()) {
            $0[$1.currentLocation, default: []].append($1)
        }
    }
    
    // 마커를 생성할 좌표와 동물 타입을 반환하는 메서드 [(type: 동물 타입, coordinate: 좌표)]
    //TODO: 화면에 보이는 지도 범위 내의 마커들만 생성해도 되지 않을까? - VC에서 설정해야할 것 같긴 함
    private func fetchMarkers(of data: [Coordinate: [Animal]]) -> [(type: AnimalType, coordinate: Coordinate)] {
        return data.reduce(into: [(type: AnimalType, coordinate: Coordinate)]()) { arr, point in
            // 타겟 좌표의 동물 타입 배열
            let types = point.value.map { $0.type }
            guard !types.isEmpty else { return }
            
            if types.count == 1 { // 동물 타입이 한가지일 경우
                arr.append((type: types.first!, coordinate: point.key))
            } else {
                var typeCount = [AnimalType: Int]() // [동물 타입: 수]
                for t in types {
                    typeCount[t, default: 0] += 1
                    
                    // 가장 수가 많은 동물 타입 (동일할 경우 가나다순)
                    let type = typeCount.sorted {
                        if $0.value != $1.value {
                            return $0.value > $1.value
                        } else {
                            return $0.key.rawValue < $1.key.rawValue
                        }
                    }.first!.key
                    
                    arr.append((type: type, coordinate: point.key))
                }
            }
        }
    }
    
    private func fetchSearchResult(text: String) throws {
        Task {
            do {
                let searchResponse = try await networkManager.searchLocationData(of: text)
                
                searchResponse.items.forEach {
                    print($0.roadAddress)
                }
            } catch {
                throw error
            }
        }
    }

}
