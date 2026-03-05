//
//  PaymentViewController.swift
//  Animality
//
//  Created by 김주희 on 3/4/26.
//

import UIKit

final class PaymentViewController: UIViewController {

    // 프로퍼티
    private let paymentView = PaymentView()
    private let viewModel: PaymentViewModel
    private let animalID: UUID

    
    // MARK: -- 초기화
    // 의존성 주입
    init(animalID: UUID, viewModel: PaymentViewModel = PaymentViewModel()) {
        self.animalID = animalID
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = paymentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "결제 하기"
        self.navigationController?.navigationBar.prefersLargeTitles = true

        bind() // VM -> View
        bindActions() // View -> VM

        // 동물 id로 데이터 불러오괴
        viewModel.action(.viewDidLoad(id: animalID))
    }

    
    // MARK: -- Binding (VM -> View)
    private func bind() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }

            self.paymentView.render(state: state)

            // 에러 메세지
            if let msg = state.errorMessage {
                let alert = UIAlertController(title: "알림", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }

            // 결제 성공
            if state.didPay {
                let alert = UIAlertController(title: "결제 완료", message: "결제가 완료되었습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true) // 화면 닫기
                })
                self.present(alert, animated: true)
            }
        }
    }
    
    
    // MARK: -- Action Binding (UI -> VM)
    private func bindActions() {
        
        // 대여 시작 날짜 변경
        paymentView.onStartDateChanged = { [weak self] date in
            self?.viewModel.action(.startDateChanged(date))
        }
        
        // 대여 종료 날짜 변경
        paymentView.onEndDateChanged = { [weak self] date in
            self?.viewModel.action(.endDateChanged(date))
        }
        
        // 결제 버튼 클릭
        paymentView.onPayTapped = { [weak self] in
            self?.viewModel.action(.payTapped)
        }
    }
}
