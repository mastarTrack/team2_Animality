//
//  PaymentViewModel.swift
//  Animality
//
//  Created by 김주희 on 3/4/26.
//
import Foundation

final class PaymentViewModel: ViewModelProtocol {
    
    // MARK: -- Action & State
    enum Action {
        case viewDidLoad(id: UUID) // 화면 로드
        case startDateChanged(Date) // 시작 날짜 변경
        case endDateChanged(Date) // 종류 날짜 변경
        case payTapped // 결제 버튼 클릭
    }

    struct State {
        var animal: Animal? = nil // 현재 선택된 동물 정보
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
    
    // 전달받은 ID로 코어데이터에서 찾아오기
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

        // flightCapability도 String? 이므로
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

    // 요금 계산 로직
    private func recalc() {
        state.didPay = false
        state.errorMessage = nil

        guard let animal = state.animal else {
            state.isPayEnabled = false
            state.totalAmount = 0
            return
        }
        
        // 종료시간 - 시작시간
        let diff = state.endDate.timeIntervalSince(state.startDate)
        guard diff > 0 else {
            state.isPayEnabled = false
            state.totalAmount = 0
            state.durationText = "시간을 다시 선택해주세요"
            state.errorMessage = "반납 시간은 시작 시간보다 이후여야 합니다."
            return
        }

        // 시간 올림(ceil) (1시간 1분 -> 2시간으로 청구됨)
        let billingHours = max(1, Int(ceil(diff / 3600.0)))

        // 화면 표시용 텍스트
        let minutes = Int(diff / 60)
        let h = minutes / 60
        let m = minutes % 60
        state.durationText = m == 0
        ? "\(h)시간 (청구 \(billingHours)시간)"
        : "\(h)시간 \(m)분 (청구 \(billingHours)시간)"

        state.totalAmount = billingHours * animal.pricePerHour
        state.isPayEnabled = true
    }

    
    // 결제하기
    private func pay() {
        guard state.isPayEnabled else { return }
        guard let animal = state.animal else { return }

        let locationText = "(\(animal.currentLocation.latitude), \(animal.currentLocation.longitude))"

        // 영수증 데이터 RentReceipt 생성
        let receipt = RentReceipt(
            id: UUID(),
            userId: UUID(),                 // 로그인 붙이면 유저 UUID 넣기
            animalId: animal.id,
            amount: Int64(state.totalAmount),
            location: locationText,
            rentPaymentTime: Date(),
            rentStartTime: state.startDate,
            rentEndTime: state.endDate,
            rentState: .renting,
            payState: .renting,
            animal: animal
        )

        // 기존 CoreData 함수 재사용해서 create
        coreDataManager.createReceiptEntity(receipt: receipt)

        state.didPay = true
    }
}
