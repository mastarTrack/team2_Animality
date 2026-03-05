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

    
    // MARK: -- 동물모델메니저 주입
    
    private let modelManager: AnimalityModelManager
    private var animalID: UUID?
    
    init(modelManager: AnimalityModelManager) {
        self.modelManager = modelManager
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

        modelManager.refreshAnimals()
        
        guard let animal = modelManager.allAnimals.first(where: { $0.id == id }) else {
                    state.errorMessage = "해당 동물을 찾을 수 없습니다."
                    state.animal = nil
                    return
        }

        state.animal = animal
    }

    private func deleteCurrent() {
        state.errorMessage = nil
        state.didDelete = false

        guard let id = animalID else {
            state.errorMessage = "삭제할 대상이 없습니다."
            return
        }

        modelManager.deleteAnimal(id: id)
        state.didDelete = true
    }

}
