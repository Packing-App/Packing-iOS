# 🧳 패킹(Packing) - 여행 준비물 관리 앱

<div align="center">
  <img src="https://github.com/Packing-App/Packing-iOS/blob/main/Packing/Packing/Resources/Assets.xcassets/AppIcon.appiconset/1024.png?raw=true" alt="Packing 로고" width="200">
  <br>
  <p><strong>여행 준비물의 스마트한 관리와 공유를 위한 iOS 애플리케이션</strong></p>
  <p>
    <a href="#✨-주요-기능">주요 기능</a> •
    <a href="#🔧-기술-스택">기술 스택</a> •
    <a href="#📐-아키텍처">아키텍처</a> •
    <a href="#🚀-설치-방법">설치 방법</a> •
    <a href="#💡-구현-내용">구현 내용</a> •
    <a href="#📱-스크린샷">스크린샷</a>
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
      <a href="https://github.com/iyungui">🔗 GitHub 프로필</a>
    </td>
  </tr>
</table>

<br>

> 혼자서 기획부터 디자인, 개발까지 모든 과정을 진행했습니다.  
> iOS 클라이언트와 Node.js 백엔드 개발을 통해 전체 시스템 아키텍처에 대한 깊은 이해를 쌓을 수 있었습니다.

</div>

---

## 📋 프로젝트 개요

**패킹(Packing)**은 여행자를 위한 맞춤형 여행 준비물 추천 및 관리 서비스입니다. 여행 목적지, 기간, 테마 등 사용자 맞춤 정보를 바탕으로 최적화된 준비물 목록을 제공하여 여행 준비의 효율성을 높이고, 동행자와 실시간으로 준비 상황을 공유할 수 있는 iOS 애플리케이션입니다.

> 여행을 떠나기 전, 항상 무엇을 챙겨야 할지 고민하고 막상 여행 중에 필요한 물건을 깜빡하는 상황을 해결하기 위해 개발했습니다.

## ✨ 주요 기능

### 1. 여행 준비물 맞춤 추천 시스템
- 목적지, 기간, 테마(바다/등산/쇼핑 등) 기반 최적화된 준비물 추천
- 날씨와 여행 목적에 맞춤화된 옷차림과 필수품 제안
- 카테고리별 체계적인 체크리스트 제공

### 2. 실시간 준비물 공유 기능
- 여행 동반자 초대 시스템을 통한 체크리스트 실시간 공유
- 공용 준비물과 개인 준비물 구분 관리
- 준비 상황 실시간 확인으로 중복 준비 방지

### 3. 스마트 리마인더 기능
- 여행지 위치 기반 날씨 정보 자동 연동
- 출발 전 준비물 점검 알림 서비스
- 기상 특이사항 발생 시 맞춤형 알림 제공

## 🔧 기술 스택

### 프론트엔드 (iOS)
- Swift 5.5+
- UIKit & SwiftUI 하이브리드 구현
- ReactorKit (단방향 데이터 흐름 아키텍처)
- RxSwift & RxCocoa
- Kingfisher (이미지 캐싱)
- KeychainSwift (보안 데이터 관리)

### 백엔드
- Node.js & Express
- MongoDB
- JWT 기반 인증 시스템
- Socket.io (실시간 통신)
- Passport.js (OAuth 인증)

## 📐 아키텍처

프로젝트는 Clean Architecture와 MVVM 패턴의 장점을 결합하여 구현했으며, ReactorKit을 통해 단방향 데이터 흐름을 관리합니다.

<div align="center">
  <img src="https://github.com/사용자명/Packing/raw/main/Resources/architecture_diagram.png" alt="아키텍처 다이어그램" width="700">
</div>

### 주요 레이어 구성

#### 🔷 애플리케이션 레이어
- AppDelegate, SceneDelegate
- Push Notification
- DI Container (의존성 주입)

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

## 🚀 설치 방법

### 요구사항
- iOS 17.0+
- Xcode 13.0+
- CocoaPods

### 설치 단계
```bash
# 저장소 클론
git clone https://github.com/Packing-App/Packing-iOS.git

# 디렉토리 이동
cd Packing

# 의존성 설치
pod install

# Xcode에서 .xcworkspace 파일 열기
open Packing.xcworkspace
```

## 💡 구현 내용

### 1. ReactorKit을 활용한 단방향 데이터 흐름
ReactorKit을 도입하여 View와 비즈니스 로직을 명확히 분리했습니다. Action -> Mutation -> State 흐름으로 데이터 변화를 예측 가능하게 관리합니다.

```swift
// Reactor 예시
final class TravelChecklistReactor: Reactor {
    enum Action {
        case fetchItems
        case toggleItem(id: String)
        case addItem(TravelItem)
    }
    
    enum Mutation {
        case setItems([TravelItem])
        case updateItem(TravelItem)
        case appendItem(TravelItem)
        case setLoading(Bool)
    }
    
    struct State {
        var items: [TravelItem] = []
        var isLoading: Bool = false
    }
}
```

### 2. RxSwift Reentrancy 문제 해결
Observable 스트림에서 발생할 수 있는 재진입(Reentrancy) 문제를 해결하기 위해 `share()`, `publishRelay`, 적절한 스케줄러 활용으로 안정적인 비동기 처리를 구현했습니다.

### 3. JWT 기반 인증 시스템
AccessToken과 RefreshToken을 활용한 보안 인증 시스템을 구현했습니다. 만료된 토큰 자동 갱신 처리 및 KeychainManager를 통한 안전한 토큰 관리가 특징입니다.

### 4. 실시간 데이터 공유
Socket.io를 활용한 실시간 준비물 체크리스트 공유 시스템을 구현했습니다. 여행 동반자와 준비 상황을 즉각적으로 동기화합니다.

### 5. iPad 화면 대응
Split View와 적응형 레이아웃을 통해 다양한 iOS 디바이스에서 최적화된 사용자 경험을 제공합니다.
