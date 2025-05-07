# 🧳 패킹(Packing) - 여행 준비물 관리 앱

<div align="center">
  <img src="https://github.com/Packing-App/Packing-iOS/blob/main/Packing/Packing/Resources/Assets.xcassets/AppIcon.appiconset/1024.png?raw=true" alt="Packing 로고" width="200">
  <br>
  <p><strong>여행 준비물의 스마트한 관리와 공유를 위한 iOS 애플리케이션</strong></p>
  <a href="https://apps.apple.com/us/app/%ED%8C%A8%ED%82%B9/id6745450311">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on the App Store" height="50">
  </a>
  <p>
    <a href="#✨-주요-기능">주요 기능</a> •
    <a href="#🔧-기술-스택">기술 스택</a> •
    <a href="#📐-아키텍처">아키텍처</a> •
    <a href="#🚀-설치-방법">설치 방법</a> •
    <a href="#💡-구현-내용">구현 내용</a>
  </p>
</div>

---

## 👨‍💻 개발자 정보

<div align="center">

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/iyungui.png" width="150" height="150" style="border-radius: 50%;" alt="iyungui 프로필 이미지" />
    </td>
  </tr>
  <tr>
    <td align="center">
      <strong>이융의 (iyungui)</strong><br>
      iOS 개발자
    </td>
  </tr>
  <tr>
    <td align="center">
      <a href="https://github.com/iyungui">GitHub Profile</a>
    </td>
  </tr>
</table>

<br>

> 혼자서 기획부터 디자인, 개발까지 모든 과정을 진행했습니다.  
> iOS 클라이언트와 Node.js 백엔드 개발을 통해 전체 시스템 아키텍처에 대한 깊은 이해를 쌓을 수 있었습니다.

</div>

---

## 📋 프로젝트 개요



**패킹(Packing)**은 여행자를 위한 맞춤형 여행 준비물 추천 및 관리 서비스입니다. 여행 목적지, 기간, 테마 등 사용자 맞춤 정보를 바탕으로 최적화된 준비물 목록을 제공하여 여행 준비의 효율성을 높이고, 여행을 같이 가는 친구와 함께 실시간으로 준비 상황을 공유할 수 있는 iOS 애플리케이션입니다.

> 여행을 떠나기 전, 무엇을 챙겨야 할지 고민해도 막상 여행 중에 필요한 물건을 깜빡하는 상황이 있습니다. 패킹은 이를 해결하기 위해 개발 되었습니다.

## ✨ 주요 기능

1. 여행 준비물 맞춤 추천 시스템

목적지, 기간, 테마(바다/등산/쇼핑 등) 기반 최적화된 준비물 추천
날씨와 여행 목적에 맞춤화된 옷차림과 필수품 제안
카테고리별 체계적인 체크리스트 제공

<div align="center">
  <img src="https://github.com/user-attachments/assets/e9fc63f6-834d-4d9f-b320-495eda45fc14" alt="Apple iPhone 16 Pro Max Screenshot 1" width="300">
  <p><em>맞춤형 준비물 추천 시스템</em></p>
</div>


2. 실시간 준비물 공유 기능

여행 파티원 초대 시스템을 통한 체크리스트 실시간 공유
공용 준비물과 개인 준비물 구분 관리

<div align="center">
  <img src="https://github.com/user-attachments/assets/c2440af9-a37a-40c1-89ab-5eeae27823bc" alt="Apple iPhone 16 Pro Max Screenshot 2" width="300">
  <p><em>실시간 준비물 공유 및 협업 기능</em></p>
</div>


3. 스마트 리마인더 기능

여행지 위치 기반 날씨 정보 자동 연동
출발 전 준비물 점검 알림 서비스
기상 특이사항 발생 시 맞춤형 알림 제공

<div align="center">
  <img src="https://github.com/user-attachments/assets/f3079d6c-4a03-4542-a1b1-535d58c66c59" alt="Apple iPhone 16 Pro Max Screenshot 3" width="300">
  <p><em>스마트 리마인더 및 날씨 연동 기능</em></p>
</div>


## 🔧 기술 스택

### 프론트엔드 (iOS)
- Swift 6.1+
- UIKit + SwiftUI 구현
- ReactorKit (단방향 데이터 흐름 아키텍처)
- RxSwift & RxCocoa
- Kingfisher (이미지 캐싱)
- KeychainSwift (토큰 데이터 관리)

### 백엔드
- Node.js & Express
- MongoDB
- JWT 기반 인증 시스템
- Socket.io (실시간 통신)
- Passport.js (OAuth 인증)

## 📐 아키텍처

로그인 화면의 경우에는 MVVM in-out으로, 나머지 UIKit 화면은 ReactorKit을 통해 단방향 데이터 흐름을 관리하도록 하였습니다.

### 주요 레이어 구성

![KakaoTalk_Photo_2025-05-06-23-57-10](https://github.com/user-attachments/assets/28a91891-542a-4d2c-995a-7b553de9b964)


#### 🔷 애플리케이션 레이어
- AppDelegate, SceneDelegate

#### 🔷 데이터 레이어
- **네트워크**: API Client, Endpoints, Error 처리
- **스토리지**: KeychainManager (액세스 토큰, 리프레시 토큰), UserManager

#### 🔷 도메인 레이어
- Models (엔티티)
- Services (비즈니스 로직)

#### 🔷 프레젠테이션 레이어
- ViewController (UI 담당)
- Reactor (상태 관리, 비즈니스 로직)

#### 🔷 확장 기능
- JourneyCreatorCoordinator: 여행 생성 프로세스
- AuthCoordinator: 인증 사용자 유무 네비게이션 프로세스

## 🚀 설치 방법

### 요구사항
- iOS 17.6+
- Xcode 16.0+
- SPM

### 설치 단계
```bash
# 저장소 클론
git clone https://github.com/Packing-App/Packing-iOS.git

# 디렉토리 이동
cd Packing

# Xcode에서 .xcodeproj 파일 열기
open Packing.xcodeproj
```

## 💡 구현 내용

대표적인 트러블 슈팅 내용은 [노션](https://silicon-distance-ef3.notion.site/Troubleshooting-1b2f678b2fe28011932eda3dc8020a00)에서도 확인 가능합니다.

### 1. ReactorKit을 활용한 단방향 데이터 흐름
ReactorKit을 도입하여 View와 비즈니스 로직을 명확히 분리했습니다. Action -> Mutation -> State -> View 흐름으로 데이터 변화를 한눈에 보기 쉽게 관리하도록 했습니다.

```swift
final class ProfileViewReactor: Reactor {
    // 사용자 액션 정의
    enum Action {...}
    
    // 상태 변경 중간 단계 이벤트
    enum Mutation {...}
    
    // 화면의 상태 정의
    struct State {...}
    
    let initialState: State


    // 뷰로부터 Action을 받아 Mutation으로 변환
    func mutate(action: Action) -> Observable<Mutation> {...}

    // Mutation를 받아 State를 변경
    func reduce(state: State, mutation: Mutation) -> State {...}
}
```

```swift
final class ProfileViewController: UIViewController, View {

    func bind(reactor: ProfileViewReactor) {
        // Action 바인딩
        button.rx.tap
            .subscribe(onNext: { [weak self] _ in })
            .disposed(by: disposeBag)
        
        // State 바인딩
        reactor.state.map { $0.isLoading }
            .subscribe(onNext: { [weak self] _ in })
            .disposed(by: disposeBag)
    }
}
```

### 2. RxSwift Reentrancy 문제 해결
Observable 스트림에서 발생할 수 있는 Reentrancy 문제를 해결하기 위해 `publishRelay`, MainScheduler 스케줄러 활용으로 안정적인 비동기 처리를 구현했습니다. -- (UI 변경로직은 메인스레드에서, 네트워크 통신은 백그라운드 스레드에서 처리)

### 3. JWT 기반 인증 시스템
AccessToken과 RefreshToken을 활용한 보안 인증 시스템을 구현했습니다. 만료된 토큰의 경우에는 자동 갱신 처리를 하여, 자동 로그인을 구현하였으며, 토큰 데이터는 KeychainManager를 통해 안전하게 관리했습니다.

### 4. iPad 화면 대응
UIDevice.current.userInterfaceIdiom == .pad 을 사용하여, 적응형 레이아웃을 구현했습니다. 이를 통해 iPhone SE부터 iPhone pro max, 그리고 iPad 디바이스에서도 최적화된 사용자 경험을 제공하도록 했습니다.
