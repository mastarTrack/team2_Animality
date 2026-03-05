//
//  DetailView.swift
//  Animality
//
//  Created by 김주희 on 3/4/26.
//
import UIKit
import SnapKit
import Then

final class DetailView: UIView {

    // MARK: - VC 전달용 클로저
    var onDeleteTapped: (() -> Void)?
    var onEditTapped: (() -> Void)?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerView = UIView().then {
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray6
    }

    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemBlue
        $0.alpha = 0.4
    }

    private let nameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textAlignment = .center
    }

    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 15
        $0.distribution = .fillEqually
    }

    private let deleteButton = UIButton(type: .system).then {
        $0.setTitle("삭제하기", for: .normal)
        $0.setTitleColor(.systemRed, for: .normal)
        $0.backgroundColor = .systemRed.withAlphaComponent(0.1)
        $0.layer.cornerRadius = 12
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) { fatalError() }

    
    // MARK: -- setupUI
    
    private func setupUI() {
        backgroundColor = .systemBackground
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        [headerView, nameLabel, infoStackView, deleteButton].forEach { contentView.addSubview($0) }
        headerView.addSubview(iconImageView)

        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(200)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(100)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }

        infoStackView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(30)
        }

        deleteButton.snp.makeConstraints {
            $0.top.equalTo(infoStackView.snp.bottom).offset(50)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    
    // MARK: -- setupActions
    
    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    @objc private func deleteTapped() {
        onDeleteTapped?()
    }

    private func createInfoRow(title: String, value: String) -> UIView {
        let container = UIView()

        let titleLabel = UILabel().then {
            $0.text = title
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .secondaryLabel
        }

        let valueLabel = UILabel().then {
            $0.text = value
            $0.font = .boldSystemFont(ofSize: 18)
        }

        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        titleLabel.snp.makeConstraints { $0.leading.centerY.equalToSuperview() }
        valueLabel.snp.makeConstraints { $0.trailing.centerY.equalToSuperview() }
        container.snp.makeConstraints { $0.height.equalTo(30) }

        return container
    }

    
    // MARK: - 데이터 주입
    func configure(with animal: Animal) {
        nameLabel.text = animal.name

        switch animal.type.category.lowercased() {
        case "ride":
            iconImageView.image = UIImage(systemName: "bicycle")
        case "pet":
            iconImageView.image = UIImage(systemName: "pawprint.fill")
        default:
            iconImageView.image = nil
        }
        
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        infoStackView.addArrangedSubview(createInfoRow(title: "종류", value: animal.type.rawValue))
        infoStackView.addArrangedSubview(createInfoRow(title: "카테고리", value: animal.type.category))
        infoStackView.addArrangedSubview(createInfoRow(title: "상태", value: animal.status.rawValue))
        infoStackView.addArrangedSubview(createInfoRow(title: "크기", value: animal.size.rawValue))
        infoStackView.addArrangedSubview(createInfoRow(title: "비행 여부", value: animal.flightCapability.rawValue))
        infoStackView.addArrangedSubview(createInfoRow(title: "시간당 가격", value: "\(animal.pricePerHour)원"))
    }
}
