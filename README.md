# Franklin 13

> 13가지 덕목으로 완성하는 나

벤자민 프랭클린의 13가지 덕목을 매일 실천하며 더 나은 나를 만들어 가는 자기계발 앱입니다.

## 소개

Franklin 13은 미국 건국의 아버지 벤자민 프랭클린이 평생 실천했던 13가지 덕목을 현대적으로 재해석한 습관 관리 앱입니다.

### 13가지 덕목 (13 Virtues)

| # | 덕목 | Virtue | 설명 |
|---|------|--------|------|
| 1 | 절제 | Temperance | 배부르도록 먹지 말고, 취하도록 마시지 말라 |
| 2 | 침묵 | Silence | 자신과 타인에게 이로운 말만 하라 |
| 3 | 질서 | Order | 모든 물건은 제자리에, 모든 일은 제때에 |
| 4 | 결단 | Resolution | 해야 할 일을 하기로 결심하라 |
| 5 | 절약 | Frugality | 자신과 타인에게 이로운 일에만 돈을 써라 |
| 6 | 근면 | Industry | 시간을 낭비하지 말라 |
| 7 | 진실 | Sincerity | 거짓으로 해를 끼치지 말라 |
| 8 | 정의 | Justice | 남에게 해를 끼치거나 의무를 게을리하지 말라 |
| 9 | 중용 | Moderation | 극단을 피하라 |
| 10 | 청결 | Cleanliness | 몸, 옷, 주거의 불결함을 참지 말라 |
| 11 | 평정 | Tranquility | 사소한 일에 마음을 어지럽히지 말라 |
| 12 | 순결 | Chastity | 건강과 자손을 위해서만 관계하라 |
| 13 | 겸손 | Humility | 예수와 소크라테스를 본받으라 |

## 주요 기능

- **13가지 덕목 관리** - 각 덕목별 상세 설명과 실천 가이드 제공
- **매일 기록** - 오늘 실천한 덕목을 간편하게 체크
- **주간 포커스** - 프랭클린처럼 매주 하나의 덕목에 집중
- **진행 상황 확인** - 덕목별 실천 현황을 한눈에 파악
- **알림 설정** - 매일 실천을 위한 리마인더

## 기술 스택

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Local Storage**: Hive
- **Authentication**: Firebase Auth (Google, Apple, Kakao)
- **Design**: Neumorphic UI

## 스크린샷

| 홈 화면 | 덕목 상세 | 설정 |
|--------|---------|------|
| 오늘의 덕목과 실천 현황 | 덕목별 상세 정보 | 알림 및 계정 관리 |

## 설치 및 실행

### 요구사항

- Flutter 3.19.0 이상
- Dart 3.3.0 이상
- iOS 12.0 이상 / Android 5.0 이상

### 설치

```bash
# 저장소 클론
git clone https://github.com/buelmanager/franklin_flow.git

# 디렉토리 이동
cd franklin_flow

# 의존성 설치
flutter pub get

# iOS 설정 (macOS만)
cd ios && pod install && cd ..

# 실행
flutter run
```

### 환경 설정

Firebase 설정이 필요합니다:

1. [Firebase Console](https://console.firebase.google.com)에서 프로젝트 생성
2. iOS/Android 앱 등록
3. `google-services.json` (Android) 및 `GoogleService-Info.plist` (iOS) 다운로드
4. 각 플랫폼 디렉토리에 파일 배치

## 프로젝트 구조

```
lib/
├── core/                    # 공통 유틸리티
│   ├── constants/          # 상수 정의
│   ├── theme/              # 앱 테마
│   └── utils/              # 유틸리티 함수
├── features/               # 기능별 모듈
│   ├── auth/              # 인증
│   ├── home/              # 홈 화면
│   ├── virtues/           # 덕목 관리
│   └── settings/          # 설정
└── main.dart              # 앱 진입점
```

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

## 연락처

- **개발자**: buelmanager
- **이메일**: [이메일 주소]
- **GitHub**: https://github.com/buelmanager/franklin_flow

---

*"We are what we repeatedly do. Excellence, then, is not an act, but a habit."*
— Will Durant (Aristotle 해석)
