//
//  RentReceiptModel.swift
//  Animality
//
//  Created by Hanjuheon on 3/4/26.
//

import Foundation

//MARK: - Temp Model & Data
/// 렌트 영수증 정보 모델
struct RentReceipt {
    /// 영수증 ID
    let id: UUID
    /// 유저 정보 ID
    let userId: UUID
    /// 대여한 동물
    let animalId: UUID
    /// 결제 금액
    let amount: Int64
    /// 대여 장소
    let location: String?
    /// 결제 시간
    let rentPaymentTime: Date
    /// 대여 시작 시간
    let rentStartTime: Date
    /// 대여 종료 시간
    let rentEndTime: Date
    /// 대여 상태
    let rentState: StateUILabel.RentState
    /// 결제 상태
    let payState: StateUILabel.RentState
    /// 동물 모델
    let animal: Animal?
    
    func formatLocation(_ location: String?) -> String {
        guard let location else { return "" }
        
        let trimmed = location
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        let components = trimmed.split(separator: ",")
        
        guard components.count == 2,
              let lat = Double(components[0]),
              let lon = Double(components[1]) else {
            return location
        }
        
        return String(format: "(%.3f, %.3f)", lat, lon)
    }
}

/// 샘플 데이터
extension RentReceipt {
    static let sample: RentReceipt = {

        let animal = Animal(
            id: UUID(),
            userId: UUID(),
            name: "황금 유니콘",
            type: .unicorn,
            status: .rented,
            pricePerHour: 100000,
            currentLocation: Coordinate(
                latitude: 37.557192,
                longitude: 126.924492
            ),
            size: .large,
            flightCapability: .canFly,
            registDate: Date()
        )

        return RentReceipt(
            id: UUID(),
            userId: UUID(),
            animalId: UUID(),
            amount: 100000,
            location: "홍대입구",
            rentPaymentTime: Date(),
            rentStartTime: Date(),
            rentEndTime: Date().addingTimeInterval(3600),
            rentState: .renting,
            payState: .completed,
            animal: animal,
        )
    }()
}
