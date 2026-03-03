//
//  SearchResponse.swift
//  Animality
//
//  Created by t2025-m0143 on 3/3/26.
//

struct SearchResponse: Codable {
    let items: [Items]
}

struct Items: Codable {
    let title: String?
    let roadAddress: String?
    let telephone: String?
    let mapx: Int?
    let mapy: Int?
}
