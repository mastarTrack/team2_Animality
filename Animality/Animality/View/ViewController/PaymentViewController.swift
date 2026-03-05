//
//  PaymentViewController.swift
//  Animality
//
//  Created by 김주희 on 3/4/26.
//

import UIKit

final class PaymentViewController: UIViewController {

    private let paymentView = PaymentView()
    private let viewModel: PaymentViewModel
    private let animalID: UUID

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

        bind()
        bindActions()

        viewModel.action(.viewDidLoad(id: animalID))
    }

    private func bind() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }

            self.paymentView.render(state: state)

            if let msg = state.errorMessage {
                let alert = UIAlertController(title: "알림", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }

            if state.didPay {
                let alert = UIAlertController(title: "결제 완료", message: "결제가 완료되었습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        }
    }

    private func bindActions() {
        paymentView.onStartDateChanged = { [weak self] date in
            self?.viewModel.action(.startDateChanged(date))
        }
        paymentView.onEndDateChanged = { [weak self] date in
            self?.viewModel.action(.endDateChanged(date))
        }
        paymentView.onPayTapped = { [weak self] in
            self?.viewModel.action(.payTapped)
        }
    }
}
