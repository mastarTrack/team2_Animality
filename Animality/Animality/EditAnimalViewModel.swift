//
//  EditAnimalViewModel.swift
//  Animality
//
//  Created by 김주희 on 3/2/26.
//

import Foundation

class EditAnimalViewModel: ViewModelProtocol {
    
    // MARK: -- Action, State 정의
    enum Action {
        case viewDidLoad
        case saveTapped(name: String?, Category: String?, type: String?, size: String?)
        case delete
    }
    
    enum State {
        case none
        case initialized(AnimalEntity)
        case saveSuccess
        case deleteSuccess
        case error(message: String)
    }
    
    var stateChanged: ((State) -> Void)?
    
    // state 상태 변경될때마다 바인딩 클로저 실행
    var state: State = .none {
        didSet {
            stateChanged?(state)
        }
    }
    
    // 초기화할때 entity 주입받기
    init(animal: AnimalEntity) {
        self.animal = animal
    }
    
    lazy var action: ((Action) -> Void)? = { [weak self] action in
        guard let self = self else { return }
        
        switch action {
            
        case .viewDidLoad:
            self.state = .initialized(self.animal)
            
        case .saveTapped(let name, let category, let type, let size):

            let updatePayload = UpdateAnimalModel(
                name: name,
                category: category,
                type: type,
                size: size
            )
                        CoreDataManager.shared.updateAnimalEntity(entity: self.animal, with: updatePayload)
            self.state = .saveSuccess
            
        case .delete:
            CoreDataManager.shared.deleteAnimalEntity(entity: self.animal)
            self.state = .deleteSuccess
        }
    }
    
    
}

