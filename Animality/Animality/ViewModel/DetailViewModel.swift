//
//  Detail.swift
//  Animality
//
//  Created by 김주희 on 3/4/26.
//
import Foundation

final class DetailViewModel: ViewModelProtocol {

    // MARK: - Action / State
    enum Action {
        case viewDidLoad(id: UUID)
        case deleteTapped
    }

    struct State {
        var animal: Animal? = nil
        var errorMessage: String? = nil
        var didDelete: Bool = false
    }

    private(set) var state: State = .init() {
        didSet { onStateChanged?(state) }
    }

    var onStateChanged: ((State) -> Void)?

    
    // MARK: -- 코어데이터 매니저 주입
    private let coreDataManager: CoreDataManager
    private var currentEntity: AnimalEntity? // 현 데이터 보관

    init(coreDataManager: CoreDataManager = CoreDataManager()) {
        self.coreDataManager = coreDataManager
    }

    
    // MARK: - Action
    func action(_ action: Action) {
        switch action {
        case .viewDidLoad(let id):
            fetch(id: id) // id에 해당하는 값 불러오기

        case .deleteTapped:
            deleteCurrent()
        }
    }

    
    // MARK: - Private
    private func fetch(id: UUID) {
        // 이전 상태 초기화
        state.errorMessage = nil
        state.didDelete = false

        guard let entity = coreDataManager.fetchOneAnimalEntity(id: id) else {
            state.errorMessage = "해당 동물을 찾을 수 없습니다."
            return
        }

        currentEntity = entity
        state.animal = mapToAnimal(entity)
    }

    private func deleteCurrent() {
        guard let entity = currentEntity else {
            state.errorMessage = "삭제할 대상이 없습니다."
            return
        }

        coreDataManager.deleteAnimalEntity(entity: entity)
        state.didDelete = true
    }

    // 코어데이터 -> 화면용 데이터로 매핑
    private func mapToAnimal(_ entity: AnimalEntity) -> Animal {
        let type = AnimalType(rawValue: entity.type ?? "") ?? .dog
        let status = AnimalStatus(rawValue: entity.status ?? "") ?? .normal
        let size = AnimalSize(rawValue: entity.size ?? "") ?? .medium
        let flight = FlightCapability(rawValue: entity.flightCapability ?? "")

        return Animal(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            type: type,
            status: status,
            pricePerHour: Int(entity.pricePerHour),
            currentLocation: Coordinate(latitude: entity.latitude, longitude: entity.longitude),
            size: size,
            flightCapability: FlightCapability(rawValue: entity.flightCapability ?? "") ?? .cannotFly
        )
    }
}
