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
        case newRegister
        case deleteRegistration
        case search(text: String)
        case cancelSearch
        case fetchAnimalOf(Coordinate)
    }
    
    // 상태 열거형
    enum State {
        case none
        case initialized(lat: Double, lng: Double, data: [Coordinate: AnimalType]) // (현재 위도, 현재 경도, 마커)
        case locationChanged(lat: Double, lng: Double)
        case deleteRegistration(data: [Coordinate: AnimalType])
        case newRegister(data: [Coordinate: AnimalType])
        case searched(result: [LocationInfo])
        case cancelledSearch
        case updateSheetAnimal([Animal])
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
            
            let data = fetchMarkerData(of: coordinates) // 생성할 마커 배열
            self.state = .initialized(lat: lat, lng: lng, data: data)
            
        case let .didUpdateLocations(lat, lng):
            self.state = .locationChanged(lat: lat, lng: lng)
         
        case .deleteRegistration:
            coordinates = categorizeAnimalByCoordinate()
            let data = fetchMarkerData(of: coordinates)
            self.state = .deleteRegistration(data: data)
            
        case .newRegister:
            coordinates = categorizeAnimalByCoordinate()
            let data = fetchMarkerData(of: coordinates)
            self.state = .newRegister(data: data)
            
        case let .search(text):
            Task {
                do {
                    let result = try await fetchSearchResult(text: text)
                    searchResults = result
                    self.state = .searched(result: result)
                } catch {
                    print("검색 결과를 가져오지 못했습니다.")
                    //                    state = 에러로
                }
            }
            
        case .cancelSearch:
            self.state = .cancelledSearch
            
        case let .fetchAnimalOf(coordinate):
            print("fetchAnimalOf")
            let animals = fetchAnimals(of: coordinate)
            self.state = .updateSheetAnimal(animals)
        }
        
    }
    
    // init
    init(modelManager: AnimalityModelManager, networkManager: NetworkManager) {
        self.modelManager = modelManager
        self.networkManager = networkManager
    }
    
    // 프로퍼티 선언
    let modelManager: AnimalityModelManager
    let networkManager: NetworkManager

    private(set) var coordinates = [Coordinate: [Animal]]() // 좌표별 동물 딕셔너리 [좌표: [동물]]
    private(set) var searchResults: [LocationInfo] = []
    
    // 좌표별 동물 분류 메서드
    private func categorizeAnimalByCoordinate() -> [Coordinate: [Animal]] {
        let animals = modelManager.allAnimals
        
        return animals.reduce(into: [Coordinate: [Animal]]()) {
            $0[$1.currentLocation, default: []].append($1)
        }
    }
    
    // 마커를 생성할 좌표와 동물 타입을 반환하는 메서드 [(type: 동물 타입, coordinate: 좌표)]
    private func fetchMarkerData(of data: [Coordinate: [Animal]]) -> [Coordinate: AnimalType] {
        return data.reduce(into: [Coordinate: AnimalType]()) { dic, point in
            // 타겟 좌표의 동물 타입 배열
            let types = point.value.map { $0.type }
            guard !types.isEmpty else { return }
            
            if types.count == 1 { // 동물 타입이 한가지일 경우
                dic[point.key] = types.first!
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
                    
                    dic[point.key] = type
                }
            }
        }
    }
    
    private func fetchSearchResult(text: String) async throws -> [LocationInfo] {
        // textField 입력값으로 검색
        let searchResponse = try await networkManager.searchLocationData(of: text)
        
        // 지역 검색 결과 title 배열
        let searchNames = searchResponse.items.compactMap { $0.title }
        
        // 지역 검색 결과의 이미지 검색
        var imageStrings: [String] = []
        for name in searchNames {
            let response = try await networkManager.searchImageData(of: name)
            let link = response.items.first?.link ?? ""
            
            imageStrings.append(link)
        }
        
        // [LocationInfo] 배열 반환
        return searchResponse.items.enumerated().reduce(into: [LocationInfo]()) {
            
            guard let name = $1.element.title,
                  let address = $1.element.roadAddress,
                  let mapX = Double($1.element.mapx ?? ""),
                  let mapY = Double($1.element.mapy ?? "") else {
                return
            }
            
            let image = imageStrings[$1.offset]
            
            $0.append(LocationInfo(name: name.htmlToString() ?? NSAttributedString(string: ""),
                                   address: address,
                                   mapX: mapX,
                                   mapY: mapY,
                                   image: image))
        }
    }
    
    private func fetchAnimals(of coordinate: Coordinate) -> [Animal] {
        coordinates = categorizeAnimalByCoordinate()// 갱신
        return coordinates[coordinate]?.sorted {
            if $0.status == .normal && $1.status != .normal {
                return true
            } else {
                return false
            }
        } ?? []
    }
}
