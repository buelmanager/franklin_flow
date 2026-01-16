# Franklin 13

벤자민 프랭클린의 13가지 덕목 기반 습관 관리 앱

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.29.0 |
| Language | Dart 3.7.0 |
| State Management | Riverpod 2.6.1 |
| Local Database | Hive 2.2.3 |
| Authentication | Firebase Auth 5.3.4 |
| UI Design | Neumorphic Design System |

## Architecture

```
lib/
├── core/                          # 공통 모듈
│   ├── constants/                 # 상수 (colors, sizes, strings)
│   ├── theme/                     # 앱 테마 설정
│   ├── widgets/                   # 공통 위젯 (NeumorphicContainer 등)
│   └── utils/                     # 유틸리티 (Logger, Extensions)
│
├── features/                      # Feature-based 모듈
│   ├── auth/                      # 인증 모듈
│   │   ├── models/               # UserModel, AuthResult
│   │   ├── services/             # AuthService, SessionService
│   │   ├── providers/            # authStateProvider
│   │   └── screens/              # LoginScreen
│   │
│   ├── home/                      # 홈 화면
│   │   ├── models/               # DailyRecord, WeeklyProgress
│   │   ├── providers/            # homeProvider
│   │   ├── screens/              # HomeScreen
│   │   └── widgets/              # HomeHeader, VirtueCard
│   │
│   ├── virtues/                   # 덕목 관리
│   │   ├── models/               # VirtueModel (Hive TypeAdapter)
│   │   ├── repositories/         # VirtueRepository
│   │   ├── providers/            # virtuesProvider
│   │   └── screens/              # VirtueDetailScreen
│   │
│   └── settings/                  # 설정
│       ├── providers/            # settingsProvider
│       └── screens/              # SettingsScreen
│
└── main.dart                      # App Entry Point
```

## Features

### Authentication
- **Social Login**: Google, Apple, Kakao
- **Email/Password**: Firebase Auth
- **Session Management**: Hive 기반 로컬 세션 저장
- **Auto Login**: 앱 시작 시 세션 복원

### State Management (Riverpod)
```dart
// Provider 정의
final virtuesProvider = StateNotifierProvider<VirtuesNotifier, VirtuesState>((ref) {
  return VirtuesNotifier(ref.read(virtueRepositoryProvider));
});

// 사용
final virtues = ref.watch(virtuesProvider);
```

### Local Storage (Hive)
```dart
// TypeAdapter 등록
@HiveType(typeId: 0)
class VirtueModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<DailyRecord> records;
}
```

### Neumorphic UI System
```dart
// 커스텀 뉴모픽 컨테이너
NeumorphicContainer(
  style: NeumorphicStyle.convex,  // flat, concave, convex, pressed
  borderRadius: AppSizes.radiusL,
  child: /* content */,
)
```

## Setup

### Requirements
- Flutter 3.19.0+
- Dart 3.3.0+
- Xcode 15.0+ (iOS)
- Android Studio / VS Code

### Installation

```bash
# Clone
git clone https://github.com/buelmanager/franklin_flow.git
cd franklin_flow

# Dependencies
flutter pub get

# iOS
cd ios && pod install && cd ..

# Code Generation (Hive TypeAdapters)
flutter pub run build_runner build --delete-conflicting-outputs

# Run
flutter run
```

### Firebase Configuration

1. Firebase Console에서 프로젝트 생성
2. iOS/Android 앱 등록
3. 설정 파일 배치:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. `lib/firebase_options.dart` 생성 (FlutterFire CLI)

```bash
flutterfire configure
```

### Social Login Setup

**Google Sign-In**
- Firebase Console > Authentication > Sign-in method > Google 활성화
- iOS: `Info.plist`에 URL Scheme 추가

**Apple Sign-In**
- Apple Developer > Identifiers > Sign In with Apple 활성화
- Firebase Console > Authentication > Apple 활성화

**Kakao Login**
- Kakao Developers > 앱 등록
- `android/app/src/main/AndroidManifest.xml` 설정
- `ios/Runner/Info.plist` URL Scheme 추가

## Build

### iOS
```bash
# Release Build
flutter build ios --release --no-tree-shake-icons

# Archive (Xcode)
open ios/Runner.xcworkspace
# Product > Archive
```

### Android
```bash
# APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9      # State Management
  hive_flutter: ^1.1.0          # Local Storage
  firebase_core: ^3.8.1         # Firebase
  firebase_auth: ^5.3.4         # Authentication
  google_sign_in: ^6.2.2        # Google Login
  sign_in_with_apple: ^6.1.4    # Apple Login
  kakao_flutter_sdk_user: ^1.10.0  # Kakao Login
  flutter_local_notifications: ^19.5.0  # Notifications
  permission_handler: ^11.0.0   # Permissions
  crypto: ^3.0.3                # Password Hashing

dev_dependencies:
  build_runner: ^2.4.13         # Code Generation
  hive_generator: ^2.0.1        # Hive TypeAdapter
  flutter_launcher_icons: ^0.13.1  # App Icons
```

## Project Structure Details

### Core Module
| File | Description |
|------|-------------|
| `app_colors.dart` | 컬러 팔레트 (Light/Dark) |
| `app_sizes.dart` | 사이즈 상수 (spacing, radius, padding) |
| `app_text_styles.dart` | 텍스트 스타일 정의 |
| `app_strings.dart` | 문자열 상수 (i18n 준비) |
| `neumorphic_container.dart` | 뉴모픽 UI 컴포넌트 |
| `app_logger.dart` | 로깅 유틸리티 |

### Data Flow
```
UI (Screen/Widget)
    ↓ watch/read
Provider (StateNotifier)
    ↓ call
Repository
    ↓ CRUD
Hive Box (Local) / Firebase (Remote)
```

## License

MIT License
