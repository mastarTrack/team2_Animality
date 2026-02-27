//
//  TestCoreDataManager.swift
//  Animality
//
//  Created by t2025-m0143 on 2/27/26.
//

class TestCoreDataManager {
    func fetchAllAnimalEntities() -> [AnimalEntity] {
        return [
            AnimalEntity(
                    name: "초코",
                    category: "포유류",
                    type: "강아지",
                    latitude: 36.1274,
                    longitude: 128.3352,
                    size: "Small",
                    pricePerHour: 12000,
                    status: "available"
                ),
                AnimalEntity(
                    name: "보리",
                    category: "포유류",
                    type: "고양이",
                    latitude: 36.1259,
                    longitude: 128.3378,
                    size: "Small",
                    pricePerHour: 10000,
                    status: "available"
                ),
                AnimalEntity(
                    name: "콩이",
                    category: "조류",
                    type: "앵무새",
                    latitude: 36.1268,
                    longitude: 128.3339,
                    size: "Medium",
                    pricePerHour: 8000,
                    status: "unavailable"
                ),
                AnimalEntity(
                    name: "마루",
                    category: "포유류",
                    type: "토끼",
                    latitude: 36.1247,
                    longitude: 128.3365,
                    size: "Small",
                    pricePerHour: 9000,
                    status: "available"
                ),
                AnimalEntity(
                    name: "레오",
                    category: "파충류",
                    type: "도마뱀",
                    latitude: 36.1283,
                    longitude: 128.3344,
                    size: "Medium",
                    pricePerHour: 11000,
                    status: "maintenance"
                )
        ]
    }
}

class AnimalEntity {
    var name: String?
    var category: String?
    var type: String?
    var latitude: Double // 위도
    var longitude: Double // 경도
    var size: String?
    var pricePerHour: Int32
    var status: String
    
    init(name: String? = nil, category: String? = nil, type: String? = nil, latitude: Double, longitude: Double, size: String? = nil, pricePerHour: Int32, status: String) {
        self.name = name
        self.category = category
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.size = size
        self.pricePerHour = pricePerHour
        self.status = status
    }
}
