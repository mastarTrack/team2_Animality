# 🦄 Animality

> **환상의 동물 대여 서비스 iOS 애플리케이션**

Animality는 지도 기반으로 주변의 **환상의 동물을 대여할 수 있는 서비스 앱**입니다.  
사용자는 지도에서 동물을 탐색하고 대여할 수 있으며, 이용 내역을 관리할 수 있습니다.

<br>

# 📱 프로젝트 소개

**Animality**는 기존 **모빌리티 공유 서비스 구조**를 기반으로  
환상의 동물을 대여하는 컨셉으로 확장한 iOS 애플리케이션입니다.

지도 위에 배치된 동물들을 확인하고 원하는 개체를 선택하여 대여할 수 있으며  
대여한 동물의 이용 기록을 관리할 수 있습니다.

<br>

# 📅 프로젝트 기간

2026.02.26 ~ 2026.03.06

<br>

# 👥 팀

**Team ETA**
| 이름 | 담당 기능 |
|---|---|
| 김주희 | 동물 등록 / 결제 / 상세 화면 |
| 변예린 | 로그인 / 지도 기능 |
| 한주헌 | 마이페이지 / 이용 내역 |

<br>

# 🏗 아키텍처

**MVVM**

### MVVM을 적용한 이유
- View와 비즈니스 로직 분리
- Massive ViewController 방지
- 테스트 가능한 구조

<br>

# 📂 프로젝트 폴더 구조

프로젝트는 **MVVM 구조에 맞게 역할별로 디렉토리를 분리**하여 관리했습니다.

```
Animality
│
├── Data
│ ├── CoreData
│ │ ├── AnimalEntity
│ │ └── ReceiptEntity
│ └── CoreDataManager
│
├── Model
│ ├── AnimalModel
│ ├── UserModel
│ ├── LocationInfo
│ ├── RentReceiptModel
│ └── TabItem
│
├── Service
│ ├── NetworkManager
│ ├── ColorService
│ ├── UserDefaultsKey
│ └── Extensions
│
├── View
│ ├── Cell
│ │ ├── SearchResultCell
│ │ └── ReceiptCell
│ │
│ └── CustomView
│ ├── LoginView
│ ├── RegisterView
│ ├── PaymentView
│ ├── PinSheetView
│ └── DetailView
│
├── ViewController
│ ├── LoginViewController
│ ├── MapViewController
│ ├── RegisterViewController
│ ├── PaymentViewController
│ ├── DetailViewController
│ ├── MyPageViewController
│ └── ReceiptDetailViewController
│
└── ViewModel
├── LoginViewModel
├── RegisterViewModel
├── PaymentViewModel
├── DetailViewModel
├── LocationViewModel
└── MyPageViewModel
```

### 구조 설계 이유
- **Data** : CoreData 관련 로직 관리  
- **Model** : 앱에서 사용하는 데이터 모델 정의  
- **Service** : 공통 서비스 및 유틸리티 관리  
- **View** : UI 구성 요소 관리  
- **ViewController** : 화면 제어  
- **ViewModel** : 비즈니스 로직 처리  

<br>

# 🧰 기술 스택

### Language
- Swift

### Architecture
- MVVM

### Storage
- CoreData
- UserDefaults

### Library
| Library | 역할 |
|---|---|
| SnapKit | AutoLayout |
| Then | 객체 초기화 |
| Alamofire | 네트워크 통신 |
| Kingfisher | 이미지 캐싱 |
| NMapsMap | 네이버 지도 |
| NMapsGeometry | 지도 좌표 처리 |

<br>

# ⭐ 핵심 기능

## 🗺 지도 기반 동물 탐색
Animality의 핵심 기능은 **지도 기반 동물 탐색 시스템**입니다.
NAVER Map API를 활용하여 지도 위에 동물의 위치를 표시하고  
사용자가 주변에서 대여 가능한 동물을 쉽게 확인할 수 있도록 구현했습니다.

### 지도 기능
- NAVER Map API를 이용한 지도 화면 구현
- 사용자 현재 위치 기반 지도 이동
- 주소 검색 기능 제공
- 지도 핀 선택 시 Bottom Sheet 표시

### 지도 핀 표시 로직
지도 위에는 동물의 위치를 나타내는 **핀(Pin)**이 표시됩니다.
이를 통해 사용자는 **대여 가능한 위치를 직관적으로 확인**할 수 있습니다.

### Bottom Sheet 리스트
핀을 선택하면 하단에서 **Bottom Sheet 형태의 리스트**가 표시됩니다.
리스트에는 다음 정보가 표시됩니다.
- 동물 이미지
- 동물 타입
- 대여 가능 여부
- 간단한 정보
사용자는 리스트에서 원하는 동물을 선택하여 **대여 화면으로 이동**할 수 있습니다.

<br>

## 🦄 동물 대여 시스템
지도에서 선택한 동물의 상세 정보를 확인하고 대여할 수 있습니다.
대여 화면에서는 다음 정보를 확인할 수 있습니다.
- 동물 이미지
- 동물 타입
- 옵션 정보
- 대여 시간
- 반납 시간

<br>

## 💳 결제 기능
동물 대여 시 결제를 진행합니다.
결제 완료 화면에서는 다음 정보를 확인할 수 있습니다.
- 결제 금액
- 대여 시간
- 반납 시간
- 동물 정보
- 대여 위치

<br>

## 📝 동물 등록
운영자는 새로운 동물을 등록할 수 있습니다.
등록 시 입력 정보
- 동물 이름
- 동물 타입
- 옵션 정보
- 위치 정보
위치는 지도에서 핀을 선택하여 저장됩니다.

<br>

## 👤 마이페이지
마이페이지에서는 다음 기능을 제공합니다.
- 이용 내역 확인
- 사용자 정보 확인 및 수정
- 등록한 동물 목록 확인

<br>

# 🛠 Troubleshooting
[버튼의 isHighlighted가 해제되지 않는 현상](https://velog.io/@bambu113/%EB%82%B4%EC%9D%BC%EB%B0%B0%EC%9B%80%EC%BA%A0%ED%94%84-260303-TIL)


<br>

# 🎨 UI 설계

Figma 기반으로 화면을 설계했습니다.
[Figma - 와이어 프레임](https://www.figma.com/design/2z5UV7xKjDDrS8SRcsE4qr/Animality)

주요 화면
- 로그인
- 지도
- 동물 대여
- 결제
- 동물 등록
- 마이페이지


<br>

# 🚀 향후 개선 사항

- 지도 반경 필터 기능
- 동물 상태 신고 기능
- 이용 내역 수정 / 삭제 기능
