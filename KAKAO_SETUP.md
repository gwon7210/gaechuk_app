# 카카오 로그인 설정 가이드

## 🔧 설정 방법

### 1. 카카오 개발자 콘솔 설정

1. [카카오 개발자 콘솔](https://developers.kakao.com/)에 접속
2. 애플리케이션 생성 
3. 플랫폼 설정에서 Android/iOS 추가
4. 키 해시 및 번들 ID 등록

### 2. 앱 키 설정 ✅ 완료

카카오 앱 키가 이미 설정되어 있습니다:

#### 설정된 앱 키
- **네이티브 앱 키**: `8169924bca4f25dd1ef4c7d44c47fa07`
- **JavaScript 키**: `2df581feb0ea368c5404ab121ec06ccf`

#### 적용된 파일들
- ✅ `lib/main.dart` (14-15번째 줄)
- ✅ `android/app/src/main/AndroidManifest.xml` (41번째 줄)
- ✅ `ios/Runner/Info.plist` (57번째 줄)

### 3. API 서버 URL 설정

`lib/services/api_client.dart` 파일의 `baseUrl`을 실제 API 서버 URL로 변경하세요:

```dart
static const String baseUrl = 'https://your-api-base-url.com';
```

## 📱 구현된 기능

### 인증 플로우
1. **카카오 로그인**: 카카오톡 앱 또는 웹 로그인
2. **사용자 상태 확인**: 서버에서 사용자 온보딩 상태 조회
3. **상태별 화면 분기**:
   - `REGISTERED_DRAFT`: 온보딩 진행
   - `PENDING_REVIEW`: 승인 대기 화면
   - `VERIFIED`: 메인 앱 화면
   - `REJECTED`: 승인 거절 화면

### 온보딩 프로세스
1. **교회 정보 입력**: 교회명, 교단, 담임목사 성함
2. **닉네임 설정**: 2-20자 닉네임
3. **신앙 고백 작성**: 50-600자 신앙 고백문

### UI 컴포넌트
- 진행상황 표시 위젯
- 상태별 전용 페이지
- 모던한 디자인의 폼 입력
- 유효성 검사 및 사용자 피드백

## 🔗 API 엔드포인트

구현된 API 호출:

- `POST /auth/kakao/login`: 카카오 로그인
- `GET /auth/status`: 사용자 상태 조회
- `PUT /onboarding/complete`: 온보딩 완료
- `POST /auth/refresh`: 토큰 갱신

## 🚀 사용 방법

1. 카카오 개발자 콘솔에서 앱 등록 및 키 발급
2. 위 설정 방법에 따라 앱 키와 서버 URL 설정
3. `flutter pub get` 실행
4. 앱 빌드 및 실행

## ⚠️ 주의사항

- 카카오 앱 키는 공개되면 안 되므로 환경변수나 별도 설정 파일로 관리하는 것을 권장
- API 서버가 준비되어야 실제 로그인 및 온보딩이 작동함
- 프로덕션 환경에서는 HTTPS 사용 필수

## 🔒 보안 고려사항

- JWT 토큰은 SharedPreferences에 안전하게 저장
- 자동 토큰 갱신 기능 포함
- API 오류 처리 및 사용자 친화적 에러 메시지

## 📝 추가 개발 필요 사항

- 프로필 이미지 업로드 기능
- 푸시 알림 설정
- 네트워크 연결 상태 확인
- 오프라인 모드 지원
