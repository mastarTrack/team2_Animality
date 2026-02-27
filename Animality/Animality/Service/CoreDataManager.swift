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
    var price: Int32
    var status: String
}

// MARK: Animal 수정 모델 구조체
struct UpdateAnimalModel {
    var name: String?
    var category: String?
    var type: String?
    var size: String?
    var latitude: Double?
    var longitude: Double?
    var price: Int32?
    var status: String?
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
                // 수정: fatalError 대신 에러를 콘솔에 출력하여 에러시에도 앱 중단 X
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
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    // saveContext - 메서드
    func doCatchSaveContext() {
        do {
            try self.saveContext()
            print("데이터 저장 성공")
        } catch {
            print("데이터 저장 실패 \(error.localizedDescription)")
            // Alert로 사용자에 알림창으로 에러 알림하는 로직 추가 예정
        }
    }
    
    // MARK: -- CRUD
    
    // MARK: CREATE
    // 개체 등록 - 개체등록 뷰에서 완료 버튼 누르면 호출할 함수
    func createAnimalEntity(with payload: CreateAnimalModel){
        let context = self.context
        
        let newEntity = AnimalEntity(context: context)
        
        newEntity.id = UUID() // ID는 자동 생성됨
        newEntity.name = payload.name
        newEntity.category = payload.category
        newEntity.type = payload.type
        newEntity.size = payload.size
        newEntity.latitude = payload.latitude // 위도
        newEntity.longitude = payload.longitude // 경도
        newEntity.pricePerHour = payload.price
        newEntity.status = payload.status
        
        doCatchSaveContext()
    }
    
    
    // MARK: READ

    // 1. 저장한 모든 개체 불러오기
    func fetchAllAnimalEntities() -> [AnimalEntity] {
        // AnimalEntity 데이터 요청
        let request: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            return entities
        } catch {
            print("데이터를 불러오는데 실패했습니다.: \(error.localizedDescription)")
            return []
        }
    }

    // 2. 특정 개체 불러오기
    func fetchOneAnimalEntity(id: UUID) -> AnimalEntity? {
        let request: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            return results.first // 일치하는 첫번째 데이터 반환
        } catch {
            print("데이터를 불러오는데 실패했습니다.: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    // MARK: UPDATE
    func updateAnimalEntity(entity: AnimalEntity, with payload: UpdateAnimalModel) {
        
        if let name = payload.name { entity.name = name }
        if let category = payload.category { entity.category = category }
        if let type = payload.type { entity.type = type }
        if let size = payload.size { entity.size = size }
        if let latitude = payload.latitude { entity.latitude = latitude }
        if let longitude = payload.longitude { entity.longitude = longitude }
        if let price = payload.price { entity.pricePerHour = price }
        if let status = payload.status { entity.status = status }
        
        doCatchSaveContext()
    }
    
    
    // MARK: DELETE
    // 등록한 개체를 상세 정보 뷰에서 삭제하기
    func deleteAnimalEntity(entity: AnimalEntity) {
        self.context.delete(entity)
        
        doCatchSaveContext()
    }
    
}
