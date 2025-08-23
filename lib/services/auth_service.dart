import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient;
  late SharedPreferences _prefs;

  bool _isInitialized = false;
  bool _isLoggedIn = false;
  UserStatusType? _userStatus;
  String? _accessToken;
  String? _refreshToken;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;
  UserStatusType? get userStatus => _userStatus;
  ApiClient get apiClient => _apiClient;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // 저장된 토큰 확인
    _accessToken = _prefs.getString('access_token');
    _refreshToken = _prefs.getString('refresh_token');

    if (_accessToken != null) {
      _apiClient.setAccessToken(_accessToken!);
      _isLoggedIn = true;

      try {
        // 사용자 상태 확인
        await _updateUserStatus();
      } catch (e) {
        // 토큰이 만료되었을 가능성이 있음
        if (_refreshToken != null) {
          try {
            await _refreshTokens();
            await _updateUserStatus();
          } catch (e) {
            // 리프레시 토큰도 만료됨
            await logout();
          }
        } else {
          await logout();
        }
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> loginWithKakao() async {
    try {
      // 카카오 로그인
      OAuthToken? token;

      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      if (token.accessToken.isEmpty) {
        throw Exception('카카오 로그인에 실패했습니다.');
      }

      // 서버에 카카오 토큰 전송하여 JWT 토큰 받기
      final authTokens = await _apiClient.kakaoLogin(token.accessToken);

      // 토큰 저장
      await _saveTokens(authTokens);

      // 사용자 상태 확인
      await _updateUserStatus();

      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      debugPrint('카카오 로그인 오류: $e');
      throw Exception('로그인에 실패했습니다: $e');
    }
  }

  Future<void> completeOnboarding(OnboardingData data) async {
    try {
      await _apiClient.completeOnboarding(data);
      await _updateUserStatus();
      notifyListeners();
    } catch (e) {
      debugPrint('온보딩 완료 오류: $e');
      throw Exception('온보딩 완료에 실패했습니다: $e');
    }
  }

  Future<void> _updateUserStatus() async {
    try {
      final status = await _apiClient.getUserStatus();
      _userStatus = _parseUserStatus(status.status);
      notifyListeners();
    } catch (e) {
      debugPrint('사용자 상태 업데이트 오류: $e');
      rethrow;
    }
  }

  UserStatusType _parseUserStatus(String status) {
    switch (status) {
      case 'REGISTERED_DRAFT':
        return UserStatusType.registeredDraft;
      case 'PENDING_REVIEW':
        return UserStatusType.pendingReview;
      case 'VERIFIED':
        return UserStatusType.verified;
      case 'REJECTED':
        return UserStatusType.rejected;
      default:
        return UserStatusType.registeredDraft;
    }
  }

  Future<void> _saveTokens(AuthTokens tokens) async {
    _accessToken = tokens.accessToken;
    _refreshToken = tokens.refreshToken;

    await _prefs.setString('access_token', tokens.accessToken);
    await _prefs.setString('refresh_token', tokens.refreshToken);

    _apiClient.setAccessToken(tokens.accessToken);
  }

  Future<void> _refreshTokens() async {
    if (_refreshToken == null) {
      throw Exception('리프레시 토큰이 없습니다.');
    }

    final tokens = await _apiClient.refreshToken(_refreshToken!);
    await _saveTokens(tokens);
  }

  Future<void> logout() async {
    try {
      // 카카오 로그아웃
      await UserApi.instance.logout();
    } catch (e) {
      debugPrint('카카오 로그아웃 오류: $e');
    }

    // 로컬 데이터 정리
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');

    _accessToken = null;
    _refreshToken = null;
    _isLoggedIn = false;
    _userStatus = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
