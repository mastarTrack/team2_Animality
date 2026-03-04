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
    let name: String
    let email: String
    let registDate: Date
    let rentalCount: Int
    
    //TODO: 한주헌 - 등록개체 모델 구현시 추가예정
    let registAnimal: [String]?
}
