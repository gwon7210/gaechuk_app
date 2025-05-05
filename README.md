# 개축 앱 (Gaechuk App)

## 프로젝트 소개
개축 앱은 Flutter를 사용하여 개발된 모바일 애플리케이션입니다.

## 기술 스택
- Flutter SDK (>=3.2.3)
- Dart SDK (>=3.2.3)
- 주요 의존성:
  - http: ^1.1.0 (HTTP 통신)
  - shared_preferences: ^2.2.2 (로컬 데이터 저장)
  - cupertino_icons: ^1.0.2 (iOS 스타일 아이콘)

## 시작하기

### 필수 요구사항
- Flutter SDK 설치
- Dart SDK 설치
- Android Studio 또는 VS Code
- iOS 개발을 위한 Xcode (macOS)

### 설치 및 실행
1. 저장소 클론
```bash
git clone [repository-url]
```

2. 의존성 설치
```bash
flutter pub get
```

3. 앱 실행
```bash
flutter run
```

## 프로젝트 구조
```
lib/
  ├── main.dart
  ├── screens/
  ├── widgets/
  ├── models/
  ├── services/
  └── utils/
```

## 라이선스
이 프로젝트는 MIT 라이선스를 따릅니다.
