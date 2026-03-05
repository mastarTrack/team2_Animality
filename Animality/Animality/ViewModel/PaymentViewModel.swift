//
//  PaymentViewModel.swift
//  Animality
//
//  Created by 김주희 on 3/4/26.
//
import Foundation

final class PaymentViewModel: ViewModelProtocol {

    enum Action {
        case viewDidLoad(id: UUID)
        case startDateChanged(Date)
        case endDateChanged(Date)
        case payTapped
    }

    struct State {
        var animal: Animal? = nil
        var startDate: Date = Date()
        var endDate: Date = Date().addingTimeInterval(3600)
        var durationText: String = "1시간 (청구 1시간)"
        var totalAmount: Int = 0
        var isPayEnabled: Bool = false
        var errorMessage: String? = nil
        var didPay: Bool = false
    }

    private(set) var state: State = .init() {
        didSet { onStateChanged?(state) }
    }
    var onStateChanged: ((State) -> Void)?

    private let coreDataManager: CoreDataManager
    private var animalID: UUID?

    init(coreDataManager: CoreDataManager = CoreDataManager()) {
        self.coreDataManager = coreDataManager
    }

    func action(_ action: Action) {
        switch action {
        case .viewDidLoad(let id):
            animalID = id
            fetchAnimal(id: id)
            recalc()

        case .startDateChanged(let date):
            state.startDate = date
            if state.endDate <= state.startDate {
                state.endDate = state.startDate.addingTimeInterval(3600)
            }
            recalc()

        case .endDateChanged(let date):
            state.endDate = date
            recalc()

        case .payTapped:
            pay()
        }
    }

    private func fetchAnimal(id: UUID) {
        guard let entity = coreDataManager.fetchOneAnimalEntity(id: id) else {
            state.errorMessage = "해당 동물을 찾을 수 없습니다."
            state.isPayEnabled = false
            return
        }

        let type = AnimalType(rawValue: entity.type ?? "") ?? .dog

        // status가 String? 이므로 안전 처리
        let statusString = entity.status ?? AnimalStatus.normal.rawValue
        let status = AnimalStatus(rawValue: statusString) ?? .normal

        let size = AnimalSize(rawValue: entity.size ?? "") ?? .medium

        // flightCapability도 String?
        let flightString = entity.flightCapability ?? FlightCapability.cannotFly.rawValue
        let flight = FlightCapability(rawValue: flightString) ?? .cannotFly

        let animal = Animal(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            type: type,
            status: status,
            pricePerHour: Int(entity.pricePerHour),
            currentLocation: Coordinate(latitude: entity.latitude, longitude: entity.longitude),
            size: size,
            flightCapability: flight
        )

        state.animal = animal
    }

    private func recalc() {
        state.didPay = false
        state.errorMessage = nil

        guard let animal = state.animal else {
            state.isPayEnabled = false
            state.totalAmount = 0
            return
        }

        let diff = state.endDate.timeIntervalSince(state.startDate)
        guard diff > 0 else {
            state.isPayEnabled = false
            state.totalAmount = 0
            state.durationText = "시간을 다시 선택해주세요"
            state.errorMessage = "반납 시간은 시작 시간보다 이후여야 합니다."
            return
        }

        // 시간 올림(ceil)
        let billingHours = max(1, Int(ceil(diff / 3600.0)))

        // 표시용 텍스트
        let minutes = Int(diff / 60)
        let h = minutes / 60
        let m = minutes % 60
        state.durationText = m == 0
        ? "\(h)시간 (청구 \(billingHours)시간)"
        : "\(h)시간 \(m)분 (청구 \(billingHours)시간)"

        state.totalAmount = billingHours * animal.pricePerHour
        state.isPayEnabled = true
    }

    private func pay() {
        guard state.isPayEnabled else { return }
        guard let animal = state.animal else { return }

        let locationText = "(\(animal.currentLocation.latitude), \(animal.currentLocation.longitude))"

        // Receipt CoreData에 저장
        coreDataManager.createReceipt(
            userId: nil,
            animalId: animal.id,
            location: locationText,
            rentStartTime: state.startDate,
            rentEndTime: state.endDate,
            amount: state.totalAmount,
            rentState: AnimalStatus.rented.rawValue, // "대여중"
            payState: "결제완료"
        )

        state.didPay = true
    }
}
