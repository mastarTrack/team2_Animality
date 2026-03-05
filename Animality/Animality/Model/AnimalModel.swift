//
//  AnimalModel.swift
//  Animality
//
//  Created by 김주희 on 2/27/26.
//

import Foundation

/*
 // 1. 화면(UI)에서 입력받은 정보로 순수 Swift Model 생성하기
 let myNewAnimal = Animal(
     id: UUID(),
     name: "모찌",
     type: .pegasus,
     status: .normal,
     pricePerHour: 12000,
     currentLocation: Coordinate(latitude: 37.123, longitude: 127.123),
     size: .large,
     flightCapability: .canFly
 )

 // 2. 이 Model을 CoreData 저장용 (이전에 만든 CreateAnimalModel)로 변환해서 Manager에게 전달해서 등록
 let payload = CreateAnimalModel(
     name: myNewAnimal.name,
     category: myNewAnimal.type.category, // enum에서 자동으로 "Ride" 추출
     type: myNewAnimal.type.rawValue,     // "페가수스" 문자열 추출
     size: myNewAnimal.size.rawValue,     // "대형" 문자열 추출
     latitude: myNewAnimal.currentLocation.latitude,
     longitude: myNewAnimal.currentLocation.longitude,
     price: Int32(myNewAnimal.pricePerHour),
     status: myNewAnimal.status.rawValue  // "대여 가능" 문자열 추출
 )

 */


// MARK: - Main Animal Model
// MARK: 앱 전체에서 사용되는 모델
struct Animal: Hashable {
    /// 고유 ID
    let id: UUID
    /// 등록한 유저의 ID
    let userId: UUID
    /// 개체 이름 (예: "모찌")
    var name: String
    /// 동물 종류 (페가수스, 강아지 등)
    let type: AnimalType
    /// 동물 상태 (대여 가능, 대여 중 ,휴식중 등)
    var status: AnimalStatus
    /// 시간당 대여 요금
    var pricePerHour: Int
    /// 현재 위치 (위도, 경도)
    var currentLocation: Coordinate
    /// 동물 사이즈
    var size: AnimalSize
    /// 비행 가능 여부 (수정: 타입 명시)
    var flightCapability: FlightCapability
    /// 개체 등록 시간
    var registDate: Date
}

// MARK: 위경도
struct Coordinate: Hashable {
    var latitude: Double
    var longitude: Double
}

// MARK: 동물 종류 정의
enum AnimalType: String, CaseIterable {
    case dog = "강아지"
    case cat = "고양이"
    case pegasus = "페가수스"
    case unicorn = "유니콘"
    case chocobo = "초코보"
    
    // 타입에 따라 카테고리 자동 반환
    var category: String {
        switch self {
        case .dog, .cat:
            return "Pet"
        case .pegasus, .unicorn, .chocobo:
            return "Ride"
        }
    }
}

// MARK:  동물 상태 정의
enum AnimalStatus: String {
    case normal = "대여 가능"
    case rented = "대여중"
    case sick = "치료중"
    case resting = "휴식중"
}

// MARK: 동물 크기
enum AnimalSize: String {
    case small = "소형"
    case medium = "중형"
    case large = "대형"
}

// MARK: 비행 가능 여부
enum FlightCapability: String {
    case canFly = "비행 가능"
    case cannotFly = "비행 불가능"
}
