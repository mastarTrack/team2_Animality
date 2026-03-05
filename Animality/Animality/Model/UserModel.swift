//
//  UserModel.swift
//  Animality
//
//  Created by Hanjuheon on 3/3/26.
//

import Foundation

/// 사용자 모델
struct UserModel {
    let uid: UUID
    var id: String
    var name: String
    var email: String
    let registDate: Date
    var rentalCount: Int
    
    //TODO: 한주헌 - 등록개체 모델 구현시 추가예정
    var registAnimal: [Animal]?
    var rentReceipt: [RentReceipt]?
}


//MARK: - SAMPLE DATA
var sampleUUID = UUID()
var sampleAnimalUUID = UUID()

extension Animal {
    
    static let sample = Animal(
        id: sampleAnimalUUID,
        userId: sampleUUID,
        name: "황금 유니콘",
        type: .unicorn,
        status: .rented,
        pricePerHour: 10000,
        currentLocation: Coordinate(
            latitude: 37.5563,
            longitude: 126.9236
        ),
        size: .large,
        flightCapability: .canFly,
        registDate: Date()
    )
}

extension RentReceipt {
    
    static let sample1 = RentReceipt(
        id: UUID(),
        userId: sampleUUID,
        animalId: sampleAnimalUUID,
        amount: 100000,
        location: "홍대입구",
        rentPaymentTime: Date(),
        rentStartTime: Date(),
        rentEndTime: Date().addingTimeInterval(3600),
        rentState: .renting,
        payState: .completed,
        animal: Animal.sample
    )
    
    static let sample2 = RentReceipt(
        id: UUID(),
        userId: sampleUUID,
        animalId: sampleAnimalUUID,
        amount: 45000,
        location: "강남역",
        rentPaymentTime: Date().addingTimeInterval(-7200),
        rentStartTime: Date().addingTimeInterval(-7200),
        rentEndTime: Date().addingTimeInterval(-3600),
        rentState: .completed,
        payState: .completed,
        animal: Animal.sample
    )
    
    static let sample3 = RentReceipt(
        id: UUID(),
        userId: sampleUUID,
        animalId: sampleAnimalUUID,
        amount: 30000,
        location: "성수역",
        rentPaymentTime: Date().addingTimeInterval(-10000),
        rentStartTime: Date().addingTimeInterval(-10000),
        rentEndTime: Date().addingTimeInterval(-8000),
        rentState: .cancel,
        payState: .cancel,
        animal: Animal.sample
    )
    
    static let sampleList: [RentReceipt] = [
        sample1,
        sample2,
        sample3
    ]
}

extension UserModel {
    
    static let sample = UserModel(
        uid: sampleUUID,
        id: "Spartan",
        name: "홍길동",
        email: "hong@test.com",
        registDate: Date(),
        rentalCount: RentReceipt.sampleList.count,
        registAnimal: [Animal.sample],
        rentReceipt: RentReceipt.sampleList
    )
}
