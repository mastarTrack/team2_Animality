//
//  SheetViewModel.swift
//  Animality
//
//  Created by t2025-m0143 on 3/6/26.
//

final class SheetViewModel: ViewModelProtocol {
    enum Action {
        case rented
    }
    
    enum State {
        case none
        case refreshed([Animal])
    }
    
    var stateChanged: ((State) -> Void)? // 상태가 변할 때마다 실행할 동작
    var state: State = .none {
        didSet {
            stateChanged?(state) // 상태가 변할 때마다 실행
        }
    }
    
    func action(_ action: Action) {
        switch action {
        case .rented:
            animals = refreshAnimals() // 동물 업데이트
            state = .refreshed(animals) // 상태 변경
        }
    }
    
    //MARK: Init
    init(modelManager: AnimalityModelManager, coordinate: Coordinate) {
        self.modelManager = modelManager
        self.coordinate = coordinate
        self.animals = refreshAnimals() // 초기 동물 세팅
    }
    
    // 프로퍼티 선언
    let modelManager: AnimalityModelManager
    let coordinate: Coordinate
    private var animals: [Animal] = []
    
    private func refreshAnimals() -> [Animal] {
        modelManager.refreshAnimals()
        let animals = modelManager.allAnimals
        return animals.filter { $0.currentLocation == coordinate }
    }
}
