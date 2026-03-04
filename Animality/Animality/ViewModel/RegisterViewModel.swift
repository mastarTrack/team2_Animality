import Foundation

class RegisterViewModel: ViewModelProtocol {
    
    let coreDataManager = CoreDataManager()
    
    
    
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
        case registerSuccess            // 저장 완료
    }
    
    // VC가 이 클로저 이용해서 상태 변화 감지
    var stateChanged: ((State) -> Void)?
    private(set) var state: State = .none {
        didSet {
            stateChanged?(state)
        }
    }
    
    
    // MARK: -- 저장용 프로퍼티
    
    // 사용자 입력값 임시 저장
    private var name: String?
    private var type: AnimalType?
    private var size: AnimalSize?
    private var flightCapability: FlightCapability?
    private var pricePerHour: Int?
    private var latitude: Double? = 37.5665 // 예시 위경도 값
    private var longitude: Double? = 123.432
    
    // VC가 호출할 Action함수
    func action(_ action: Action) {
        switch action {
            
        case .enterName(let name):
            self.name = name
            
        case .sizeSelected(let size):
            self.size = size
            
        case .typeSelected(let type):
            self.type = type
            
        case .flightCapabilitySelected(let flight):
            self.flightCapability = flight
            
        case .pricePerHour(let price):
            self.pricePerHour = Int(price)
            
        case .locationSelected(let lat, let lon):
            self.latitude = lat
            self.longitude = lon
            
        case .registerTapped:
            self.register() // 저장 로직 실행
            return
        }
        validate() // 값이 들어올때마다 검사하기
    }
    
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
    
//    private func register() {
//        
//        // 하나라도 빠져있으면 경고
//        guard
//            let name,
//            let type,
//            let size,
//            let pricePerHour,
//            let flightCapability,
//            let latitude,
//            let longitude
//        else {
//            state = .showAlert("모든 항목을 입력해주세요.")
//            return
//        }
//        
//        // 도메인 모델 생성
//        let animal = Animal(
//            id: UUID(),
//            name: name,
//            type: type,
//            status: .normal,
//            pricePerHour: Int(pricePerHour),
//            currentLocation: Coordinate(latitude: latitude, longitude: longitude),
//            size: size,
//            flightCapability: flightCapability
//        )
//        
//        // 코어데이터용 payload 생성하기
//        let payload = CreateAnimalModel(
//            name: animal.name,
//            category: animal.type.category,
//            type: animal.type.rawValue,
//            size: animal.size.rawValue,
//            latitude: animal.currentLocation.latitude,
//            longitude: animal.currentLocation.longitude,
//            price: Int32(animal.pricePerHour),
//            status: animal.status.rawValue,
//            flight: animal.flightCapability.rawValue
//        )
//
//        coreDataManager.createAnimalEntity(with: payload)
//        
//        // 저장 완료 상태 저장
//        state = .registerSuccess
//    }
    
    private func register() {
        
//        // 하나라도 빠져있으면 경고
//        guard
//            let name,
//            let type,
//            let size,
//            let pricePerHour,
//            let flightCapability,
//            let latitude,
//            let longitude
//        else {
//            state = .showAlert("모든 항목을 입력해주세요.")
//            return
//        }
//        
//        // 도메인 모델 생성
//        let animal = Animal(
//            id: UUID(),
//            name: name,
//            type: type,
//            status: .normal,
//            pricePerHour: Int(pricePerHour),
//            currentLocation: Coordinate(latitude: latitude, longitude: longitude),
//            size: size,
//            flightCapability: flightCapability
//        )
//        
//        // 코어데이터용 payload 생성하기
//        let payload = CreateAnimalModel(
//            name: animal.name,
//            category: animal.type.category,
//            type: animal.type.rawValue,
//            size: animal.size.rawValue,
//            latitude: animal.currentLocation.latitude,
//            longitude: animal.currentLocation.longitude,
//            price: Int32(animal.pricePerHour),
//            status: animal.status.rawValue,
//            flight: animal.flightCapability.rawValue
//        )
//
//        coreDataManager.createAnimalEntity(with: payload)
        
        // 저장 완료 상태 저장
        state = .registerSuccess
    }
}

