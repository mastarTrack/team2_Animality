//
//  DetailViewController.swift
//  Animality
//
//  Created by 김주희 on 3/4/26.
//

import UIKit

final class DetailViewController: UIViewController {

    private let detailView = DetailView()
    private let viewModel: DetailViewModel

    var animalID: UUID?

    var updateClosure: (()->Void)?
    
    // 초기화
    // 의존성 주입
    init(animalID: UUID, modelManager: AnimalityModelManager) {
        self.viewModel = DetailViewModel(modelManager: modelManager)
        self.animalID = animalID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() { view = detailView }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "상세 정보"
        bind()
        bindActions()

        guard let id = animalID else {
            print("Error: animalID is nil")
            navigationController?.popViewController(animated: true)
            return
        }
        // 바인딩 이후에 액션 호출
        viewModel.action(.viewDidLoad(id: id))
    }

    
    private func bind() {
        viewModel.onStateChanged = { [weak self] state in
            self?.render(state)
        }
    }

    
    private func render(_ state: DetailViewModel.State) {
        
        if let animal = state.animal {
            detailView.configure(with: animal)
        }

        if let message = state.errorMessage {
            let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        }

    }

    
    private func bindActions() {
        detailView.onDeleteTapped = { [weak self] in
            self?.updateClosure?()
            self?.navigationController?.popViewController(animated: true)
            guard let nav = self?.tabBarController?.viewControllers?.first as? UINavigationController else { return }
            guard let mapVC = nav.viewControllers.first as? MapViewController else { return }
            mapVC.deleteRegistration()
            self?.viewModel.action(.deleteTapped)
        }
    }
}
