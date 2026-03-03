import Foundation

class RegisterViewModel: ViewModelProtocol {
    
    // MARK: -- Action, State
    
    enum Action {
        case enterName(String)
        case typeSelected(AnimalType)
        case sizeSelected(AnimalSize)
        case pricePerHour(String)
        case flightCapabilitySelected(FlightCapability)
        case locationSelected(Double, Double)
        case registerTapped
    }
    
    enum State {
        case none
        case validationChanged(Bool)    // 버튼 활성화 여부
        case showAlert(String)
        case registerSuccess
    }
    
    // VC가 이 클로저 이용해서 상태 변화 감지
    var stateChanged: ((State) -> Void)?
    
    var state: State = .none {
        didSet {
            stateChanged?(state)
        }
    }
    
    lazy var action: ((Action) -> Void)? = { [weak self] action in
        guard let self else { return }
        
        switch action {
            
        case .enterName(let name):
            self.name = name
            self.validate()         // 유효성 검사

        case .sizeSelected(let size):
            self.size = size
            self.validate()
            
        case .typeSelected(let type):
            self.type = type
            self.validate()
            
        case .flightCapabilitySelected(let flight):
            self.flightCapability = flight
            self.validate()
            
        case .pricePerHour(let price):
            if let priceValue = Int32(price) {
                self.pricePerHour = priceValue
            } else {
                self.pricePerHour = nil
            }
            self.validate()
            
        case .locationSelected(let lat, let lon):
            self.latitude = lat
            self.longitude = lon
            self.validate()
            
        case .registerTapped:
            self.register() // 저장 로직 실행
        }
    }
    
    
    // MARK: -- 저장용 프로퍼티
    
    // 사용자 입력값 임시 저장
    private var name: String?
    private var type: AnimalType?
    private var size: AnimalSize?
    private var flightCapability: FlightCapability?
    private var pricePerHour: Int32?
    private var latitude: Double?
    private var longitude: Double?
    
    
    // MARK: -- 유효성 검사 Validation
    
    private func validate() {
        
        // 모든 프로퍼티가 nil값이 아닌지
        let isValid =
        !(name?.isEmpty ?? true) &&
        type != nil &&
        latitude != nil &&
        longitude != nil &&
        size != nil &&
        pricePerHour != nil &&
        flightCapability != nil
        
        // 버튼 활성화 여부 View에 전달하기
        state = .validationChanged(isValid)
    }
    
    
    // MARK: -- 저장
    
    private func register() {
        
        // 하나라도 빠져있으면 경고
        guard
            let name,
            let type,
            let size,
            let pricePerHour,
            let flightCapability,
            let latitude,
            let longitude
        else {
            state = .showAlert("모든 항목을 입력해주세요.")
            return
        }
        
        // 도메인 모델 생성
        let animal = Animal(
            id: UUID(),
            name: name,
            type: type,
            status: .normal,
            pricePerHour: Int(pricePerHour),
            currentLocation: Coordinate(latitude: latitude, longitude: longitude),
            size: size,
            flightCapability: flightCapability
        )
        
        // 코어데이터용 payload 생성하기
        let payload = CreateAnimalModel(
            name: animal.name,
            category: animal.type.category,
            type: animal.type.rawValue,
            size: animal.size.rawValue,
            latitude: animal.currentLocation.latitude,
            longitude: animal.currentLocation.longitude,
            pricePerHour: Int32(animal.pricePerHour),
            status: animal.status.rawValue,
            flightCapability: animal.flightCapability == .canFly ? "가능" : "불가"
        )
        
        CoreDataManager.shared.createAnimalEntity(with: payload)
        
        // 저장 완료 상태 저장
        state = .registerSuccess
    }
}
