//
//  CoreDataManager.swift
//  Animality
//
//  Created by 김주희 on 2/27/26.
//

import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    
    // MARK: - Core Data stack
    // persistentContainer 설정
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Animality")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // 수정: fatalError 대신 에러를 콘솔에 출력, 및 앱을 계속 가동시킴
                print("CoreData 로드 실페: \(error.localizedDescription)")
                
                // Alert로 사용자에 알림창으로 에러 알림하는 로직 추가 예정
            }
        })
        return container
    }()
    
    // context로 데이터 추출
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    // MARK: - Core Data Saving support
    // 변경 사항이 있을 경우 데이터 저장
    func saveContext () throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    
    // MARK: -- CRUD
    
    // CREATE
    // 개체 등록 - 개체등록 뷰에서 완료 버튼 누르면 호출할 함수
    func createAnimalEntity(name: String, category: String, type: String, size: String, latitude: Double, longitude: Double, price: Int32){
        let context = self.context
        
        let newEntity = AnimalEntity(context: context)
        
        newEntity.id = UUID()
        newEntity.name = name
        newEntity.category = category
        newEntity.type = type
        newEntity.size = size
        newEntity.latitude = latitude // 위도
        newEntity.longitude = longitude // 경도
        newEntity.pricePerHour = price
        
        doCatchSaveContext()
    }
    
    // READ
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
    
    
    // UPDATE
    // 등록한 개체를 상세 정보 뷰에서 수정하기
    func updateAnimalEntity(entity: AnimalEntity, newName: String?, newCategory: String?, newType: String?, newSize: String?, newLatitude: Double?, newLongitude: Double?, newPrice: Int32?){
        
        if let name = newName { entity.name = name }
        if let category = newCategory { entity.category = category }
        if let type = newType { entity.type = type }
        if let size = newSize { entity.size = size }
        if let latitude = newLatitude { entity.latitude = latitude }
        if let longitude = newLongitude { entity.longitude = longitude }
        if let price = newPrice { entity.pricePerHour = price }
        
        doCatchSaveContext()
    }
    
    
    // DELETE
    // 등록한 개체를 상세 정보 뷰에서 삭제하기
    func deleteAnimalEntity(entity: AnimalEntity) {
        self.context.delete(entity)
        
        doCatchSaveContext()
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
}
