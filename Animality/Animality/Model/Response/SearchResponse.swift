//
//  SearchResponse.swift
//  Animality
//
//  Created by t2025-m0143 on 3/3/26.
//

struct SearchResponse: Codable {
    let items: [Items]
    
    enum CodingKeys: CodingKey {
        case items
    }
}

struct Items: Codable {
    let title: String?
    let roadAddress: String?
    let telephone: String?
    let mapx: String?
    let mapy: String?
    
    enum CodingKeys: CodingKey {
        case title
        case roadAddress
        case telephone
        case mapx
        case mapy
    }
}
