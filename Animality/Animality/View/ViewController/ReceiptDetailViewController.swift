//
//  Untitled.swift
//  Animality
//
//  Created by Hanjuheon on 2/27/26.
//

import UIKit
import Then
import SnapKit

/// 영수증 ViewController
class ReceiptDetailViewController: UIViewController {
    
    //MARK: - ViewModel
    
    //MARK: - Enum
    enum pageType {
        case detail
        case endPay
    }
    
    // MARK: - State
    private let type: pageType
    
    //MARK: - Closures
    /// 마이페이지(이용내역) 클로저
    var myPageClosure: (()->Void)?
    
    //MARK: - Components
    /// 렌트 상태 라벨
    private let stateLabel = StateUILabel()
    /// 결제금약 라벨
    private let totalAmountLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textAlignment = .right
    }
    /// 이름 라벨
    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    /// 대여 장소 라벨
    private let rentLocationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    /// 결제 시간 라벨
    private let rentpaymentTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    /// 대여 시작시간 라벨
    private let rentStartTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    /// 대여 종료시간 라벨
    private let rentEndTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    /// 결제상태 라벨
    private let payState = StateUILabel()
    
    /// 돌아가기 버튼
    private let returnButton = UIButton().then {
        $0.setTitle("돌아가기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 24
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    /// 이용내역 돌아가기 버튼
    private let mypageButton = UIButton().then {
        $0.setTitle("이용내역 보기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 24
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.systemGray.cgColor
    }
    

    
    
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureUI(type: type)
    }
    
    init(type: pageType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - METHOD: Update UI
extension ReceiptDetailViewController {
    func updateUI(rentState: StateUILabel.state,
                  amount: Int,
                  name: String,
                  location: String,
                  rentpaymentTime: Date,
                  rentStartTime: Date,
                  rentEndTime: Date,
                  paystate: StateUILabel.state
    ) {
        stateLabel.updateUI(state: rentState, nil)
        totalAmountLabel.text = amount.formatted(.number)
        nameLabel.text = name
        rentLocationLabel.text = location
        rentpaymentTimeLabel.text = rentpaymentTime.formatted()
        rentStartTimeLabel.text = rentStartTime.formatted()
        rentEndTimeLabel.text = rentEndTime.formatted()
        payState.updateUI(state: paystate, nil)
    }
}

//MARK: - METHOD: Button Action Binding
extension ReceiptDetailViewController {
    
    private func bindingButtonAction(type: pageType) {
        if type == .endPay {
            mypageButton.addAction(UIAction { [weak self] _ in
                self?.myPageClosure?()
            }, for: .touchUpInside)
        }
        returnButton.addAction(UIAction { [weak self] _ in
            self?.returnPage()
        }, for: .touchUpInside)
    }
    
    private func returnPage(){
        navigationController?.popViewController(animated: true)
    }
}



//MARK: - METHOD: Configure UI
extension ReceiptDetailViewController {
    private func ConfigureUI(type: pageType) {
        
        bindingButtonAction(type: type)
        
        let reciptView = UIView().then {
            $0.backgroundColor = .deepRose
            $0.layer.cornerRadius = 24
            $0.layer.borderColor = UIColor.systemGray.cgColor
            $0.layer.borderWidth = 0.5
        }
        
        let reciptStackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 4
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
        
        let payTitle = UILabel().then {
            $0.text = "💳 결제 금액"
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        let nameTitle = UILabel().then {
            $0.text = "🦮 개체 이름"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let locationTitle = UILabel().then {
            $0.text = "📌 대여 장소"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let rentPayDateTitle = UILabel().then {
            $0.text = "🗓️ 대여 일자"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let rentStartTitle = UILabel().then {
            $0.text = "⏱️ 시작 시간"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let rentEndTitle = UILabel().then {
            $0.text = "⏱️ 반납 시간"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let payStateTitle = UILabel().then {
            $0.text = "📊 결제 상태"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkText
            $0.textAlignment = .natural
        }
        
        let lineViews = (0..<3).reduce(into: [UIView]()) { result, _ in
            let view = UIView().then {
                $0.backgroundColor = .systemGray
            }
            result.append(view)
        }
        
        let payStack = UIStackView(arrangedSubviews:[payTitle, totalAmountLabel])
        let nameStack = UIStackView(arrangedSubviews: [nameTitle, nameLabel])
        let locationStack = UIStackView(arrangedSubviews: [locationTitle, rentLocationLabel])
        let rentDateStack = UIStackView(arrangedSubviews: [rentPayDateTitle, rentpaymentTimeLabel])
        let rentStartStack = UIStackView(arrangedSubviews: [rentStartTitle, rentStartTimeLabel])
        let rentEndStack = UIStackView(arrangedSubviews: [rentEndTitle, rentEndTimeLabel])
        let payStateStack = UIStackView(arrangedSubviews: [payStateTitle, payState])
        
        [payStack, nameStack, locationStack, rentDateStack, rentStartStack, rentEndStack, payStateStack].forEach {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .fillEqually
        }
        
        reciptStackView.addArrangedSubview(payStack)
        reciptStackView.addArrangedSubview(lineViews[0])
        reciptStackView.addArrangedSubview(nameStack)
        reciptStackView.addArrangedSubview(locationStack)
        reciptStackView.addArrangedSubview(lineViews[1])
        reciptStackView.addArrangedSubview(rentDateStack)
        reciptStackView.addArrangedSubview(rentStartStack)
        reciptStackView.addArrangedSubview(rentEndStack)
        reciptStackView.addArrangedSubview(lineViews[2])
        reciptStackView.addArrangedSubview(payStateStack)
        reciptView.addSubview(reciptStackView)
        
        view.addSubview(stateLabel)
        view.addSubview(reciptView)

        stateLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(122)
            $0.height.equalTo(36)
        }
        reciptView.snp.makeConstraints {
            $0.top.equalTo(stateLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(330)
            $0.height.equalTo(370)
        }
        reciptStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().inset(30)
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().inset(5)
        }
        
        [payStack, nameStack, locationStack, rentDateStack, rentStartStack, rentEndStack, payStateStack].forEach{
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(30)
                $0.trailing.equalToSuperview().inset(30)
            }
        }
        lineViews.forEach {
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(30)
                $0.trailing.equalToSuperview().inset(30)
                $0.height.equalTo(1)
            }
        }
        
        view.addSubview(returnButton)
        switch type {
        case .detail:
            returnButton.snp.makeConstraints {
                $0.top.equalTo(reciptView.snp.bottom).offset(30)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(45)

            }
        case .endPay:
            view.addSubview(mypageButton)
            mypageButton.snp.makeConstraints {
                $0.top.equalTo(reciptView.snp.bottom).offset(30)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(45)
            }
            returnButton.snp.makeConstraints {
                $0.top.equalTo(mypageButton.snp.bottom).offset(15)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(45)
            }
        }
    }
}




@available(iOS 17.0, *)
#Preview {
    let vc = ReceiptDetailViewController(type: .endPay)
    vc.updateUI(rentState: .renting, amount: 100000, name: "황금 유니콘", location: "홍대입구", rentpaymentTime: Date(), rentStartTime: Date(), rentEndTime: Date(), paystate: .completed)
    return vc

}


