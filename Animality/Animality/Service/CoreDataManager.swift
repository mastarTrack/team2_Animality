//
//  CoreDataManager.swift
//  Animality
//
//  Created by 김주희 on 2/27/26.
//

import CoreData

// MARK: Animal 등록 모델 구조체
struct CreateAnimalModel {
    var name: String
    var category: String
    var type: String
    var size: String
    var latitude: Double
    var longitude: Double
    var pricePerHour: Int32
    var status: String
    var flightCapability: String
}

// MARK: Animal 수정 모델 구조체
struct UpdateAnimalModel {
    var name: String?
    var category: String?
    var type: String?
    var size: String?
    var latitude: Double?
    var longitude: Double?
    var pricePerHour: Int32?
    var status: String?
    var flightCapability: String?
}


// MARK: -- 코어데이터 매니저
class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    
    // MARK: - Core Data stack
    // persistentContainer 설정
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Animality")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("CoreData 로드 실페: \(error.localizedDescription)")
                // Alert로 사용자에 알림창으로 에러 알림하는 로직 추가 예정
            }
        })
        return container
    }()
    
    // context로 데이터 추출
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    // MARK: - Core Data Saving support
    // 변경 사항이 있을 경우 데이터 저장
    private func saveContext () throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    
    // MARK: -- CRUD
    
    // MARK: CREATE
    // 개체 등록 - 개체등록 뷰에서 완료 버튼 누르면 호출할 함수
    func createAnimalEntity(with payload: CreateAnimalModel) throws {
        let newEntity = AnimalEntity(context: context)
        
        newEntity.id = UUID() // ID는 자동 생성됨
        newEntity.name = payload.name
        newEntity.category = payload.category
        newEntity.type = payload.type
        newEntity.size = payload.size
        newEntity.latitude = payload.latitude // 위도
        newEntity.longitude = payload.longitude // 경도
        newEntity.pricePerHour = payload.pricePerHour
        newEntity.status = payload.status
        newEntity.flightCapability = payload.flightCapability
        
        try saveContext()
    }
    
    
    // MARK: READ

    // 1. 저장한 모든 개체 불러오기
    func fetchAllAnimalEntities() throws -> [AnimalEntity] {
        // AnimalEntity 데이터 요청
        let request: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
            return try context.fetch(request)
    }

    // 2. 특정 개체 불러오기
    func fetchOneAnimalEntity(id: UUID) throws -> AnimalEntity? {
        let request: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return try context.fetch(request).first
    }
    
    
    // MARK: UPDATE
    func updateAnimalEntity(entity: AnimalEntity, with payload: UpdateAnimalModel) throws {
        
        if let name = payload.name { entity.name = name }
        if let category = payload.category { entity.category = category }
        if let type = payload.type { entity.type = type }
        if let size = payload.size { entity.size = size }
        if let latitude = payload.latitude { entity.latitude = latitude }
        if let longitude = payload.longitude { entity.longitude = longitude }
        if let pricePerHour = payload.pricePerHour { entity.pricePerHour = pricePerHour }
        if let status = payload.status { entity.status = status }
        if let flightCapability = payload.flightCapability { entity.flightCapability = flightCapability }
        
        try saveContext()
    }
    
    
    // MARK: DELETE
    // 등록한 개체를 상세 정보 뷰에서 삭제하기
    func deleteAnimalEntity(entity: AnimalEntity) throws {
        self.context.delete(entity)
        try saveContext()
    }
    
}
