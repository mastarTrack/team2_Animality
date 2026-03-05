import Foundation

class RegisterViewModel: ViewModelProtocol {
    
    private let modelManager: AnimalityModelManager
    
    init(modelManager: AnimalityModelManager) {
        self.modelManager = modelManager
    }
    
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
    private var latitude: Double? = 37.5563 // 예시 위경도 값
    private var longitude: Double? = 126.9236
    
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
        
        let now = Date() // 등록 버튼 클릭 시점의 시간 저장
        
        // 코어데이터용 payload 생성하기
        let payload = CreateAnimalModel(
            name: name,
            userId: modelManager.user.uid,
            category: type.category,
            type: type.rawValue,
            size: size.rawValue,
            latitude: latitude,
            longitude: longitude,
            price: Int32(pricePerHour),
            status: AnimalStatus.normal.rawValue,
            flight: flightCapability.rawValue,
            registDate: now
        )

        // 저장 완료 상태 저장
        modelManager.createAnimal(payload: payload)
        state = .registerSuccess
    }
}

