# 🧳 패킹(Packing) - 여행 준비물 관리 앱

<div align="center">
  <img src="https://github.com/Packing-App/Packing-iOS/blob/main/Packing/Packing/Resources/Assets.xcassets/AppIcon.appiconset/1024.png?raw=true" alt="Packing 로고" width="200">
  <br>
  <p><strong>여행 준비물의 스마트한 관리와 공유를 위한 iOS 애플리케이션</strong></p>
  <a href="https://apps.apple.com/us/app/%ED%8C%A8%ED%82%B9/id6745450311">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on the App Store" height="80">
  </a>
  <p>
    <a href="#-주요-기능">주요 기능</a> •
    <a href="#-기술-스택">기술 스택</a> •
    <a href="#-아키텍처">아키텍처</a> •
    <a href="#-설치-방법">설치 방법</a> •
    <a href="#-주요-트러블-슈팅">트러블 슈팅</a>
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
      iOS Developer
    </td>
  </tr>
  <tr>
    <td align="center">
      <a href="https://github.com/iyungui">GitHub Profile</a>
    </td>
  </tr>
</table>

<br>

> 혼자서 기획부터 디자인, 개발까지 모든 과정을 진행했습니다.<br>
> iOS 클라이언트와 Node.js 백엔드 개발을 통해 전체 시스템 아키텍처에 대한 깊은 이해를 쌓을 수 있었습니다.<br>
> iOS 개발의 경우, Rx와 단방향 아키텍쳐에 대해서 깊이있게 이해할 수 있었습니다.

</div>

---

## 📋 프로젝트 개요

**패킹(Packing)**은 여행자를 위한 맞춤형 여행 준비물 추천 및 관리 서비스입니다. 여행 목적지, 기간, 테마 등 사용자 맞춤 정보를 바탕으로 최적화된 준비물 목록을 제공하여 여행 준비의 효율성을 높이고, 여행을 같이 가는 친구와 함께 실시간으로 준비 상황을 공유할 수 있는 iOS 애플리케이션입니다.

> 여행을 떠나기 전, 무엇을 챙겨야 할지 고민해도 막상 여행 중에 필요한 물건을 깜빡하는 상황이 있습니다. 패킹은 이를 해결하기 위해 개발 되었습니다.

## ✨ 주요 기능

📱 스크린샷

<table>
  <tr>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/5938b3d8-44ac-42fb-913d-0ad1c592dc19" alt="패킹-런치스크린" width="300">
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/e9fc63f6-834d-4d9f-b320-495eda45fc14" alt="여행 맞춤별 준비물 시스템" width="300">
    </td>
    <td align="center" width="25%">
  <img src="https://github.com/user-attachments/assets/c2440af9-a37a-40c1-89ab-5eeae27823bc" alt="실시간 준비물 공유 기능" width="300">
    </td>
    <td align="center" width="25%">
  <img src="https://github.com/user-attachments/assets/f3079d6c-4a03-4542-a1b1-535d58c66c59" alt="스마트 리마인더 기능" width="300">
    </td>
  </tr>
  <tr>
    <td align="center">
      <strong>런치스크린</strong><br>
      <sub>패킹 앱 런치스크린</sub>
    </td>
    <td align="center">
      <strong>여행 테마 선택 화면</strong><br>
      <sub>여행 준비물 추천 하기 이전,<br> 여행 테마(목적)을 선택하는 컬렉션 뷰</sub>
    </td>
    <td align="center">
      <strong>여행 상세 화면</strong><br>
      <sub>여행지 사진, 참가자, 날씨, 준비물 섹션 확인</sub>
    </td>
    <td align="center">
      <strong>푸시 알림 화면</strong><br>
      <sub>- 파티/친구 추가 알림<br> - 여행 전 날 날씨 체크 및 준비물 리마인더</sub>
    </td>
  </tr>
</table>

**1. 여행 준비물 맞춤 추천 시스템**
목적지, 기간, 테마(바다/등산/쇼핑 등) 기반 최적화된 준비물 추천
날씨와 여행 목적에 맞춤화된 옷차림과 필수품 제안
카테고리별 체계적인 체크리스트 제공

**2. 실시간 준비물 공유 기능**
여행 파티원 초대 시스템을 통한 체크리스트 실시간 공유
공용 준비물과 개인 준비물 구분 관리

**3. 스마트 리마인더 기능 (APNS)**
여행지 위치 기반 날씨 정보 자동 연동
출발 전 준비물 점검 알림 서비스
기상 특이사항 발생 시 맞춤형 알림 제공

### 그 외 기능, 화면
🎯 추가 스크린샷
<table>
  <tr>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/c3489103-f7f6-481c-92e1-cf71271a7071" alt="여행 준비물 추천 화면" width="100%"/>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/33e82bbe-9562-4ae9-ba0c-7b57e2519b89" alt="친구 목록 화면" width="100%"/>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/5ff65154-f604-46ab-a12b-464a1ef039c3" alt="도시 검색 화면" width="100%"/>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/a5e99b22-15dd-47f0-a699-62ed194a82cd" alt="날씨 정보" width="100%"/>
    </td>
  </tr>
  <tr>
    <td align="center">
      <strong>여행 준비물 추천 화면</strong><br>
      <sub>목적지와 기간을 입력받아 여행 기간의 날씨를 받아오고, 이를 바탕으로 여행 준비물을 추천하도록 하였습니다.<br>이때 날씨뿐만 아니라, 사용자가 선택한 교통 수단, 여행의 목적(테마)의 정보를 바탕으로 디테일하게 맞춤형 준비물을 제공하도록 했습니다.</sub>
    </td>
    <td align="center">
      <strong>친구 검색, 목록 화면</strong><br>
      <sub>친구 목록, 요청 중인 친구 목록 화면입니다. RxSwift와 RxCocoa를 사용하여 UISearchController의 검색어 입력을 관찰하고, 일정 시간(debounce) 후 중복되지 않는 입력만 Reactor에 전달하여 처리하는 로직을 추가했습니다.</sub>
    </td>
    <td align="center">
      <strong>도시 검색 화면</strong><br>
      <sub>친구 검색과 마찬가지로 Rx로 상태를 관찰하여 UI가 즉각적으로 업데이트 되도록 하였으며, 도시 검색은 국가 코드, 국가명으로 한국어, 영어 모두 검색 가능합니다.</sub>
    </td>
    <td align="center">
      <strong>준비물 목록</strong><br>
      <sub>준비물은 개인 준비물과 공용 준비물로 나누어, 파티원과 체계적으로 여행을 준비할 수 있도록 설계했습니다. 개인 준비물의 경우, 상대방에게 보이지 않습니다.</sub>
    </td>
  </tr>
</table>

4. 여행지 사진은 unsplash image api를 사용하여, 해당 여행지(도시)의 사진을 바로 제공합니다.
5. 날씨 정보는 openweathermap api 를 사용하여 해당 기간, 목적지의 날씨 정보를 제공합니다.
6. 회원탈퇴한 유저의 경우, 친구목록에 Unknown User로 뜨게 하는 예외 처리
7. 프로필 화면 - Social Login Type, intro 등 기본적인 프로필 정보를 표시
8. 그 외 개인정보처리방침, 서비스 이용약관 등의 정보는 노션에 연결 [WKWebView 사용]

## 🔧 기술 스택

### 프론트엔드 (iOS)
- Swift 6.1+
- UIKit + SwiftUI 구현
- ReactorKit (단방향 데이터 흐름 아키텍처)
- RxSwift & RxCocoa
- RxDataSources
- Swift concurrency task, async await (SwiftUI View에 사용)
- Kingfisher (이미지 캐싱)
- KeychainSwift (토큰 데이터 관리)
- UIKit Codebase (No storyboard)
- UICollectionView, UITableView 등

### 백엔드
- Node.js & Express
- MongoDB
- JWT 기반 인증 시스템
- Socket.io (실시간 통신)
- Passport.js (OAuth 인증)
- SendGrid (이메일 인증 시 사용), AWS S3 (이미지 저장), Unsplash API, OpenWeather API

## 📐 아키텍처

- 로그인 화면의 경우에는 MVVM in-out으로, 나머지 UIKit 화면은 ReactorKit을 통해 단방향 데이터 흐름을 관리하도록 하였습니다.
- 여행 상세 화면인 JourneyDetailView의 경우에는 SwiftUI로 구현하였습니다. UIKit 프로젝트에서 UIHostingController로 보여주었습니다. 간단한 단일 뷰 였기 때문에 그리고 SwiftUI의 철학 상, 따로 뷰모델을 굳이 만들지 않았습니다.

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
- SPM (RxSwift, RxDataSources, KeychainAccess, ReactorKit, RxCocoa)

### 설치 단계
```bash
# 저장소 클론
git clone https://github.com/Packing-App/Packing-iOS.git

# 디렉토리 이동
cd Packing

# Xcode에서 .xcodeproj 파일 열기
open Packing.xcodeproj
```

## 💡 주요 트러블 슈팅

대표적인 트러블 슈팅 내용은 [노션](https://silicon-distance-ef3.notion.site/Troubleshooting-1b2f678b2fe28011932eda3dc8020a00)에서 자세히 볼 수 있습니다.

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
