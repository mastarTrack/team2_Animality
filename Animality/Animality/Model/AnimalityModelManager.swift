//
//  AnimalityModelManager.swift
//  Animality
//
//  Created by Hanjuheon on 3/5/26.
//

import Foundation

/// Animality Model Manager
class AnimalityModelManager {
    
    // MARK: - Properties
    /// CoreDataManager
    private let coreDataManager = CoreDataManager()
    /// 유저 정보 모델
    private(set) var user: UserModel
    /// 전체 개체 리스트
    private(set) var allAnimals: [Animal] = []
    
    //MARK: - Init
    init(user: UserModel, coreDataManager: CoreDataManager) {
        self.user = user
        refreshAnimals()
        refreshReceipts()
    }
}

// MARK: - METHOD: Rrfresh Date
extension AnimalityModelManager {
    /// 전체 개체 업데이트 메소드
    func refreshAnimals() {
        allAnimals = coreDataManager.fetchAllAnimalEntities()
    }
    /// User Receipts 업데이트 메소드
    func refreshReceipts() {
        let receipt = coreDataManager.fetchReceipts(userId: user.uid)
        user.rentReceipt = receipt.map { attachAnimal(receipt: $0) }
    }
}

// MARK: - Animal CRUD
extension AnimalityModelManager {
    /// 동물 등록
    func createAnimal(payload: CreateAnimalModel) {
        coreDataManager.createAnimalEntity(with: payload)
        refreshAnimals()
    }

    /// 동물 업데이트 (id 기반)
    func updateAnimal(id: UUID, payload: UpdateAnimalModel) {
        coreDataManager.updateAnimalEntity(id: id, with: payload)   // ✅ 아래 extension 추가 필요
        refreshAnimals()
    }

    /// 동물 삭제 (id 기반)
    func deleteAnimal(id: UUID) {
        // CoreDataManager에 id 기반 delete가 없어서 entity fetch 후 delete하는 래퍼 제공
        if let entity = coreDataManager.fetchOneAnimalEntity(id: id) {
            coreDataManager.deleteAnimalEntity(entity: entity)
            refreshAnimals()
        }
    }
}

// MARK: - Receipt CRUD
extension AnimalityModelManager {
    func createReceipt(_ receipt: RentReceipt) {
        coreDataManager.createReceiptEntity(receipt: receipt)
        refreshReceipts()
    }

    func updateReceipt(_ receipt: RentReceipt) {
        coreDataManager.updateReceiptEntity(receipt: receipt)
        refreshReceipts()
    }

    func deleteReceipt(id: UUID) {
        coreDataManager.deleteReceiptEntity(id: id)
        refreshReceipts()
    }
    
    private func attachAnimal(receipt: RentReceipt) -> RentReceipt {
            guard receipt.animal == nil else { return receipt }
            guard let animal = allAnimals.first(where: { $0.id == receipt.animalId }) else { return receipt }

            return RentReceipt(
                id: receipt.id,
                userId: receipt.userId,
                animalId: receipt.animalId,
                amount: receipt.amount,
                location: receipt.location,
                rentPaymentTime: receipt.rentPaymentTime,
                rentStartTime: receipt.rentStartTime,
                rentEndTime: receipt.rentEndTime,
                rentState: receipt.rentState,
                payState: receipt.payState,
                animal: animal
            )
        }
}
