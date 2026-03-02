//
//  EditViewController.swift
//  Animality
//
//  Created by 김주희 on 3/1/26.
//

import UIKit

class EditAnimalViewController: UIViewController {
    
    // MARK: -- View,VM 인스턴스 생성
    // private let editAnimalView = EditAnimalView()
    private let editAnimalviewModel: EditAnimalViewModel
    
    // 초기화
    init(viewModel: EditAnimalViewModel) {
        self.editAnimalviewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: -- 초기화
    override func loadView() {
        // self.view = editAnimalView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션바 타이틀 설정
        self.title = "상세 정보"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        bindingData()
        editAnimalviewModel.action?(.viewDidLoad)
    }
    
    // MARK: -- 메서드 정의
    // 데이터 바인딩
    private func bindingData() {
        
        // View의 Action -> VM으로 전달
        editAnimalView.tappedSaveButton = { [weak self] in
            guard let self = self else { return }
            
            let name = self.editAnimalView.nameTextField.text
            let category = self.editAnimalView.currentCategory // 예시: 선택된 카테고리
            let type = self.editAnimalView.currentType
            let size = self.editAnimalView.currentSize
            self.editAnimalviewModel.action?(.saveTapped(
                name: name,
                category: category,
                type: type,
                size: size
            ))
        }
        
        // VM의 state 변화 -> View 업데이트
        editAnimalviewModel.stateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.render(state)
            }
        }
        
    }
    
    // VM의 state 상태에 따라 View 렌더링하기
    private func render(_ state: EditAnimalViewModel.State) {
        switch state {
        case .none:
            break
            
        case .initialized(let animal):
            //editAnimalView.configure(with: animal)
            
        case .saveSuccess():
            print("객체 수정 완료")
            self.navigationController?.popViewController(animated: true)
            
        case .deleteSuccess():
            self.navigationController?.popViewController(animated: true)
            
        case .error(let message):
            showErrorAlert(message: message)
        }
    }

    
    
}
