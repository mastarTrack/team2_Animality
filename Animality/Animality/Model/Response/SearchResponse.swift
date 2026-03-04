//
//  SearchResponse.swift
//  Animality
//
//  Created by t2025-m0143 on 3/3/26.
//

// 지역 검색 API 응답 모델
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

// 이미지 검색 API 응답 모델
struct ImageResponse: Codable {
    let items: [ImageItems]
}

struct ImageItems: Codable {
    let link: String?
}
