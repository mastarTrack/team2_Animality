//
//  CoreDataManager.swift
//  Animality
//
//  Created by 김주희 on 2/27/26.
//

import CoreData

// MARK: -- 코어데이터 매니저
final class CoreDataManager {

    // MARK: - Core Data stack
    // persistentContainer 설정
    private let persistentContainer: NSPersistentContainer
        
        init() {
            persistentContainer = NSPersistentContainer()
            persistentContainer.loadPersistentStores { _, error in
                if let error = error {
                    print("CoreData 로드 실패: \(error.localizedDescription)")
                }
            }
        }

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
    
    
    
    // MARK: - animalEntity CRUD
    
    // MARK: CREATE
    // 개체 등록 - 개체등록 뷰에서 완료 버튼 누르면 호출할 함수
    func createAnimalEntity(animal: borrowing Animal){
        let context = self.context
        guard let entity = NSEntityDescription.entity(forEntityName: AnimalEntity.className, in: context)
        else { return }
        
        let newEntity = NSManagedObject(entity: entity, insertInto: context)
        
        newEntity.setValue(animal.id, forKey: AnimalEntity.keys.id)
        newEntity.setValue(animal.name, forKey: AnimalEntity.keys.name)
        newEntity.setValue(animal.type.category, forKey: AnimalEntity.keys.category)
        newEntity.setValue(animal.type.rawValue, forKey: AnimalEntity.keys.type)
        newEntity.setValue(animal.size.rawValue, forKey: AnimalEntity.keys.size)
        newEntity.setValue(animal.currentLocation.latitude, forKey: AnimalEntity.keys.latitude)
        newEntity.setValue(animal.currentLocation.longitude, forKey: AnimalEntity.keys.longitude)
        newEntity.setValue(Int32(animal.pricePerHour), forKey: AnimalEntity.keys.pricePerHour)
        newEntity.setValue(animal.status.rawValue, forKey: AnimalEntity.keys.status)
        newEntity.setValue(animal.flightCapability.rawValue, forKey: AnimalEntity.keys.flightCapability)

        doCatchSaveContext()
    }
    
    
    // MARK: READ
    // 1. 저장한 모든 개체 불러오기
    func fetchAllAnimalEntities() -> [Animal] {
        // AnimalEntity 데이터 요청
        let request: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            
            return entities.reduce(into: [Animal]()) {
                $0.append( Animal(
                    id: $1.id ?? UUID(),
                    name: $1.name ?? "",
                    type: AnimalType(rawValue: $1.type ?? "") ?? .dog,
                    status: AnimalStatus(rawValue: $1.status) ?? .normal,
                    pricePerHour: Int($1.pricePerHour),
                    currentLocation: Coordinate(latitude: $1.latitude, longitude: $1.longitude),
                    size: AnimalSize(rawValue: $1.size ?? "") ?? .medium,
                    flightCapability: FlightCapability(rawValue: $1.flightCapability ?? "") ?? .cannotFly
                ))
            }
        } catch {
            print("데이터를 불러오는데 실패했습니다.: \(error.localizedDescription)")
            return []
        }
    }

    // 2. 특정 개체 불러오기
    func fetchOneAnimalEntity(id: UUID) -> Animal? {
        let request: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            guard let entity = try context.fetch(request).first else { return nil }
            
            return Animal(
                id: entity.id ?? UUID(),
                name: entity.name ?? "",
                type: AnimalType(rawValue: entity.type ?? "") ?? .dog,
                status: AnimalStatus(rawValue: entity.status) ?? .normal,
                pricePerHour: Int(entity.pricePerHour),
                currentLocation: Coordinate(latitude: entity.latitude, longitude: entity.longitude),
                size: AnimalSize(rawValue: entity.size ?? "") ?? .medium,
                flightCapability: FlightCapability(rawValue: entity.flightCapability ?? "") ?? .cannotFly
            )
        } catch {
            print("데이터를 불러오는데 실패했습니다.: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    // MARK: UPDATE
    func updateAnimalEntity(animal: borrowing Animal) {
        let request: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", animal.id as CVarArg)

        do {
            guard let entity = try context.fetch(request).first else {
                print("해당 AnimalEntity를 찾을 수 없습니다.")
                return
            }

            entity.name = animal.name
            entity.category = animal.type.category
            entity.type = animal.type.rawValue
            entity.size = animal.size.rawValue
            entity.latitude = animal.currentLocation.latitude
            entity.longitude = animal.currentLocation.longitude
            entity.pricePerHour = Int32(animal.pricePerHour)
            entity.status = animal.status.rawValue
            entity.flightCapability = animal.flightCapability.rawValue

            doCatchSaveContext()

        } catch {
            print("업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: DELETE
    // 등록한 개체를 상세 정보 뷰에서 삭제하기
    func deleteAnimalEntity(id: UUID) {
        
        let request: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                doCatchSaveContext()
            } else {
                print("삭제할 AnimalEntity를 찾을 수 없습니다.")
            }
        } catch {
            print("삭제 실패: \(error.localizedDescription)")
        }
    }
}
