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
    var userId: UUID
    var category: String
    var type: String
    var size: String
    var latitude: Double
    var longitude: Double
    var price: Int32
    var status: String
    var flight: String
    var registDate: Date
}

// MARK: Animal 수정 모델 구조체
struct UpdateAnimalModel {
    var name: String?
    var userId: UUID?
    var category: String?
    var type: String?
    var size: String?
    var latitude: Double?
    var longitude: Double?
    var price: Int32?
    var status: String?
    var flight: String?
    var registDate: Date?
}


// MARK: -- 코어데이터 매니저
final class CoreDataManager {

    // MARK: - Core Data stack
    // persistentContainer 설정
    private let persistentContainer: NSPersistentContainer
        
        init() {
            persistentContainer = NSPersistentContainer(name: "Animality")
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
}

// MARK: - Receipt CRUD
extension CoreDataManager {
    // 영수증 생성 메소드
    func createReceiptEntity(receipt: borrowing RentReceipt) {
        let context = self.context
        
        guard let entity = NSEntityDescription.entity(
            forEntityName: Receipt.entity().name ?? "Receipt",
            in: context
        ) else { return }

        let newEntity = NSManagedObject(entity: entity, insertInto: context)

        newEntity.setValue(receipt.id, forKey: Receipt.keys.id)
        newEntity.setValue(receipt.userId, forKey: Receipt.keys.userId)
        newEntity.setValue(receipt.animalId, forKey: Receipt.keys.animalId)
        newEntity.setValue(receipt.amount, forKey: Receipt.keys.amount)
        newEntity.setValue(receipt.location, forKey: Receipt.keys.location)
        newEntity.setValue(receipt.rentPaymentTime, forKey: Receipt.keys.rentPaymentTime)
        newEntity.setValue(receipt.rentStartTime, forKey: Receipt.keys.rentStartTime)
        newEntity.setValue(receipt.rentEndTime, forKey: Receipt.keys.rentEndTime)
        newEntity.setValue(receipt.rentState.rawValue, forKey: Receipt.keys.rentState)
        newEntity.setValue(receipt.payState.rawValue, forKey: Receipt.keys.payState)

        doCatchSaveContext()
    }

    // 전체 영수증 읽기 메소드
    func fetchAllReceiptEntities() -> [RentReceipt] {
        let request: NSFetchRequest<Receipt> = Receipt.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: Receipt.keys.rentPaymentTime, ascending: false)
        ]
        
        do {
            let entities = try context.fetch(request)

            return entities.reduce(into: [RentReceipt]()) { result, entity in
                guard
                    let id = entity.id,
                    let userId = entity.userId,
                    let animalId = entity.animalId,
                    let rentPaymentTime = entity.rentPaymentTime,
                    let rentStartTime = entity.rentStartTime,
                    let rentEndTime = entity.rentEndTime,
                    let rentStateRaw = entity.rentState,
                    let payStateRaw = entity.payState,
                    let rentState = StateUILabel.state(rawValue: rentStateRaw),
                    let payState = StateUILabel.state(rawValue: payStateRaw)
                else { return }

                result.append(
                    RentReceipt(
                        id: id,
                        userId: userId,
                        animalId: animalId,
                        amount: entity.amount,
                        location: entity.location,
                        rentPaymentTime: rentPaymentTime,
                        rentStartTime: rentStartTime,
                        rentEndTime: rentEndTime,
                        rentState: rentState,
                        payState: payState,
                        animal: nil // 필요하면 fetchOneAnimalEntity로 붙이기
                    )
                )
            }
        } catch {
            print("영수증 데이터를 불러오는데 실패했습니다.: \(error.localizedDescription)")
            return []
        }
    }
    
    // userId와 일치하는 영수증들 불러오기 메소드
    func fetchReceipts(userId: UUID) -> [RentReceipt] {
            let request: NSFetchRequest<Receipt> = Receipt.fetchRequest()
            request.predicate = NSPredicate(format: "\(Receipt.keys.userId) == %@", userId as CVarArg)

            // 최신 결제 시간 순
            request.sortDescriptors = [
                NSSortDescriptor(key: Receipt.keys.rentPaymentTime, ascending: false)
            ]

            do {
                let entities = try context.fetch(request)

                return entities.reduce(into: [RentReceipt]()) { result, entity in
                    guard
                        let id = entity.id,
                        let uid = entity.userId,
                        let animalId = entity.animalId,
                        let rentPaymentTime = entity.rentPaymentTime,
                        let rentStartTime = entity.rentStartTime,
                        let rentEndTime = entity.rentEndTime,
                        let rentStateRaw = entity.rentState,
                        let payStateRaw = entity.payState,
                        let rentState = StateUILabel.state(rawValue: rentStateRaw),
                        let payState = StateUILabel.state(rawValue: payStateRaw)
                    else { return }

                    result.append(
                        RentReceipt(
                            id: id,
                            userId: uid,
                            animalId: animalId,
                            amount: entity.amount,
                            location: entity.location,
                            rentPaymentTime: rentPaymentTime,
                            rentStartTime: rentStartTime,
                            rentEndTime: rentEndTime,
                            rentState: rentState,
                            payState: payState,
                            animal: nil
                        )
                    )
                }
            } catch {
                print("유저 영수증 fetch 실패: \(error.localizedDescription)")
                return []
            }
        }
    

    /// 특정 영수증 불러오기 메소드
    func fetchOneReceiptEntity(id: UUID) -> RentReceipt? {
        let request: NSFetchRequest<Receipt> = Receipt.fetchRequest()
        request.predicate = NSPredicate(format: "\(Receipt.keys.id) == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            guard let entity = try context.fetch(request).first else { return nil }

            guard
                let rid = entity.id,
                let userId = entity.userId,
                let animalId = entity.animalId,
                let rentPaymentTime = entity.rentPaymentTime,
                let rentStartTime = entity.rentStartTime,
                let rentEndTime = entity.rentEndTime,
                let rentStateRaw = entity.rentState,
                let payStateRaw = entity.payState,
                let rentState = StateUILabel.state(rawValue: rentStateRaw),
                let payState = StateUILabel.state(rawValue: payStateRaw)
            else { return nil }

            return RentReceipt(
                id: rid,
                userId: userId,
                animalId: animalId,
                amount: entity.amount,
                location: entity.location,
                rentPaymentTime: rentPaymentTime,
                rentStartTime: rentStartTime,
                rentEndTime: rentEndTime,
                rentState: rentState,
                payState: payState,
                animal: nil
            )
        } catch {
            print("영수증 데이터를 불러오는데 실패했습니다.: \(error.localizedDescription)")
            return nil
        }
    }

    /// 영수증 업데이트 메소드
    func updateReceiptEntity(receipt: borrowing RentReceipt) {
        let request: NSFetchRequest<Receipt> = Receipt.fetchRequest()
        request.predicate = NSPredicate(format: "\(Receipt.keys.id) == %@", receipt.id as CVarArg)
        request.fetchLimit = 1

        do {
            guard let entity = try context.fetch(request).first else {
                print("해당 Receipt를 찾을 수 없습니다.")
                return
            }

            entity.userId = receipt.userId
            entity.animalId = receipt.animalId
            entity.amount = receipt.amount
            entity.location = receipt.location
            entity.rentPaymentTime = receipt.rentPaymentTime
            entity.rentStartTime = receipt.rentStartTime
            entity.rentEndTime = receipt.rentEndTime
            entity.rentState = receipt.rentState.rawValue
            entity.payState = receipt.payState.rawValue

            doCatchSaveContext()
        } catch {
            print("영수증 업데이트 실패: \(error.localizedDescription)")
        }
    }

    /// 영수증 삭제 (id 기준) 메소드
    func deleteReceiptEntity(id: UUID) {
        let request: NSFetchRequest<Receipt> = Receipt.fetchRequest()
        request.predicate = NSPredicate(format: "\(Receipt.keys.id) == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                doCatchSaveContext()
            } else {
                print("삭제할 Receipt를 찾을 수 없습니다.")
            }
        } catch {
            print("영수증 삭제 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - animalEntity CRUD

extension CoreDataManager {
    // MARK: CREATE
    // 개체 등록 - 개체등록 뷰에서 완료 버튼 누르면 호출할 함수
    func createAnimalEntity(with payload: CreateAnimalModel){
        let context = self.context
        let newEntity = AnimalEntity(context: context)
        
        newEntity.id = UUID() // ID는 자동 생성됨
        newEntity.userId = payload.userId
        newEntity.name = payload.name
        newEntity.category = payload.category
        newEntity.type = payload.type
        newEntity.size = payload.size
        newEntity.latitude = payload.latitude // 위도
        newEntity.longitude = payload.longitude // 경도
        newEntity.pricePerHour = payload.price
        newEntity.status = payload.status
        newEntity.flightCapability = payload.flight
        newEntity.registDate = payload.registDate
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
                    userId: $1.userId ?? UUID(),
                    name: $1.name ?? "",
                    type: AnimalType(rawValue: $1.type ?? "") ?? .dog,
                    status: AnimalStatus(rawValue: $1.status ?? "") ?? .normal,
                    pricePerHour: Int($1.pricePerHour),
                    currentLocation: Coordinate(latitude: $1.latitude, longitude: $1.longitude),
                    size: AnimalSize(rawValue: $1.size ?? "") ?? .medium,
                    flightCapability: FlightCapability(rawValue: $1.flightCapability ?? "") ?? .cannotFly,
                    registDate: $1.registDate ?? Date()
                ))
            }
        } catch {
            print("데이터를 불러오는데 실패했습니다.: \(error.localizedDescription)")
            return []
        }
    }

    // 2. 특정 개체 불러오기
    func fetchOneAnimalEntity(id: UUID) -> AnimalEntity? {
        let request: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first // 일치하는 첫번째 데이터 반환
        } catch {
            print("데이터를 불러오는데 실패했습니다.: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    // MARK: UPDATE
    func updateAnimalEntity(id: UUID, with payload: UpdateAnimalModel) {
        let request: NSFetchRequest<AnimalEntity> = AnimalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            guard let entity = try context.fetch(request).first else { return }

            if let name = payload.name { entity.name = name }
            if let userId = payload.userId { entity.userId = userId }
            if let category = payload.category { entity.category = category }
            if let type = payload.type { entity.type = type }
            if let size = payload.size { entity.size = size }
            if let latitude = payload.latitude { entity.latitude = latitude }
            if let longitude = payload.longitude { entity.longitude = longitude }
            if let price = payload.price { entity.pricePerHour = price }
            if let status = payload.status { entity.status = status }
            if let flight = payload.flight { entity.flightCapability = flight }
            if let registDate = payload.registDate { entity.registDate = registDate }

            doCatchSaveContext()
        } catch {
            print("업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: DELETE
    // 등록한 개체를 상세 정보 뷰에서 삭제하기
    func deleteAnimalEntity(entity: AnimalEntity) {
        self.context.delete(entity)
        doCatchSaveContext()
    }
}

