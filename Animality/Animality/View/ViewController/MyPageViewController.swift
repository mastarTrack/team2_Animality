//
//  MyPageViewController.swift
//  Animality
//
//  Created by Hanjuheon on 3/2/26.
//

import UIKit
import Then
import SnapKit


class MyPageViewController : UIViewController {
    
    //MARK: - ViewModel
    
    //MARK: - Components
    /// 유저 타이틀 이미지
    private let titleImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 40
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.systemGray6.cgColor
    }
    /// 유저 타이틀 아이디 라벨
    private let titleNameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
    }
    /// 유저 아이디 라벨
    private let idLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
    }
    /// 유저 이름 텍스트 필드
    private let nameField = UITextField().then {
        $0.font = .boldSystemFont(ofSize: 20)
    }
    /// 유저 이메일 텍스트 필드
    private let emailField = UITextField().then {
        $0.font = .boldSystemFont(ofSize: 20)
    }
    /// 유저 가입날짜 라벨
    private let registLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
    }
    /// 유저 렌탈 횟수 라벨
    private let rentCountLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
    }

    /// 사용자 정보 수정버튼
    private let modifyButton = UIButton().then {
        $0.setTitle("사용자 정보 수정", for: .normal)
        $0.setTitle("수정 완료", for: .selected)
        $0.backgroundColor = .white
        $0.setTitleColor(.systemGray, for: .normal)
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    /// 등록 내역 버튼
    private let rentRegistListButton = UIButton().then {
        $0.setTitle("등록 내역", for: .normal)
        $0.backgroundColor = .white
        $0.setTitleColor(.systemGray, for: .normal)
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray.cgColor
    }
    /// 수정 취소 버튼
    private let modifyCancelButton = UIButton().then {
        $0.setTitle("수정 취소", for: .normal)
        $0.backgroundColor = .white
        $0.setTitleColor(.systemGray, for: .normal)
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray.cgColor
        $0.isHidden = true
    }
    
    //MARK: - Closures
    /// 수정 완료 클로저
    var approveModifyClosure: (()->Void)?
    /// 수정 취소 클로져
    var cancelModifyClosure: (()->Void)?
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
}

//MARK: - Update UI
extension MyPageViewController {
    /// UI 업데이트 메소드
    func updateUI(image: UIImage, id: String, name: String, email: String, registDate: Date, rentCount: Int) {
        titleImage.image = image
        titleNameLabel.text = name
        nameField.text = name
        idLabel.text = id
        emailField.text = email
        registLabel.text = registDate.formatted()
        rentCountLabel.text = String(rentCount)
    }
    
    /// 사용자 정보 수정 메소드
    private func setEditingMode(_ isEditing: Bool) {
        modifyButton.isSelected = isEditing

        [nameField, emailField].forEach { field in
            field.isUserInteractionEnabled = isEditing
            field.borderStyle = isEditing ? .roundedRect : .none
            field.backgroundColor = isEditing ? .secondarySystemBackground : .clear
        }

        modifyCancelButton.isHidden = !isEditing
        rentRegistListButton.isHidden = isEditing

        if !isEditing { view.endEditing(true) }
    }
}

//MARK: - MATHOD: Configure UI
extension MyPageViewController {
    private func configureUI() {

        let titleView = UIView().then{
            $0.backgroundColor = .deepSerenity
            $0.layer.cornerRadius = 40
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.systemGray6.cgColor
        }
        titleView.addSubview(titleImage)
        titleView.addSubview(titleNameLabel)

        
        let ui = [idLabel, nameField, emailField, registLabel, rentCountLabel]
        
        let titleLabels = ["아이디", "이름", "이메일", "가입 날짜", "렌탈 횟수"].map{
            title -> UILabel in
            let label = UILabel().then {
                $0.text = title
                $0.font = .systemFont(ofSize: 14)
                $0.textColor = .systemGray
                $0.textAlignment = .left
            }
            return label
        }
        
        let stackViews = (0..<ui.count).map { _ -> UIStackView in
            let stackView = UIStackView().then {
                $0.backgroundColor = .systemGray6
                $0.axis = .horizontal
                $0.alignment = .center
                $0.layer.cornerRadius = 10
                $0.isLayoutMarginsRelativeArrangement = true
                $0.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            }
            return stackView
        }
        
        view.addSubview(titleView)
        for i in 0..<ui.count {
            stackViews[i].addArrangedSubview(titleLabels[i])
            stackViews[i].addArrangedSubview(ui[i])
            view.addSubview(stackViews[i])
        }

        modifyButton.addAction( UIAction { [weak self] _ in
            guard let self else { return }
            self.modifyButton.isSelected.toggle()
            let next = self.modifyButton.isSelected
            self.setEditingMode(next)

            if next == false {
                // 저장/종료 시점 콜백
                self.approveModifyClosure?()
            }
            }, for: .touchUpInside )
        
        modifyCancelButton.addAction( UIAction { [weak self] _ in
            guard let self else { return }
            self.setEditingMode(false)
            self.cancelModifyClosure?()
        }, for: .touchUpInside )
        
        rentRegistListButton.addAction( UIAction { [weak self] _ in
            guard let self else { return }
            // TODO: 등록 목록 화면 전환 코드 추가 예정
        }, for: .touchUpInside )
        
        view.addSubview(modifyButton)
        view.addSubview(rentRegistListButton)
        view.addSubview(modifyCancelButton)
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(180)
            $0.width.equalTo(300)
            $0.centerX.equalToSuperview()
        }

        titleImage.snp.makeConstraints {
            $0.height.width.equalTo(80)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(35)
        }
        titleNameLabel.snp.makeConstraints {
            $0.top.equalTo(titleImage.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        stackViews[0].snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(titleView.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
        }
        
        for stack in 1..<stackViews.count {
            stackViews[stack].snp.makeConstraints{
                $0.height.equalTo(50)
                $0.top.equalTo(stackViews[stack-1].snp.bottom).offset(15)
                $0.leading.equalToSuperview().offset(30)
                $0.trailing.equalToSuperview().inset(30)
            }
        }
        
        modifyButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(stackViews[stackViews.count-1].snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
        }
        
        rentRegistListButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(modifyButton.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
        }
        
        modifyCancelButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(modifyButton.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().inset(30)
        }
        
    }
}

@available(iOS 17.0, *)
#Preview {
    let vc = MyPageViewController()
    let image = UIImage()
    vc.updateUI(image: image, id: "godzx3", name: "한주헌", email: "xxx@xxxxx.xxx", registDate: Date(), rentCount: 0)
    return vc
}
