import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../config/environment.dart';

class ApiClient {
  String get baseUrl => Env.baseUrl;

  final http.Client _client;
  String? _accessToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  Future<AuthTokens> kakaoLogin(String kakaoAccessToken) async {
    final request =
        Env.environment == Environment.dev
            ? KakaoLoginRequest(
              accessToken: 'test_token',
              mockKakaoId: 'test_user_123',
              gender: 'M',
              birthdate: '1990-01-01',
              phone: '01012345678',
            )
            : KakaoLoginRequest(accessToken: kakaoAccessToken);

    final response = await _client.post(
      Uri.parse('$baseUrl/auth/kakao'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return AuthTokens.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException('카카오 로그인에 실패했습니다: ${response.statusCode}');
    }
  }

  Future<UserStatus> getUserStatus() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/auth/status'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return UserStatus.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException('사용자 상태 조회에 실패했습니다: ${response.statusCode}');
    }
  }

  Future<void> completeOnboarding(OnboardingData data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/onboarding/complete'),
      headers: _headers,
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode != 204) {
      throw ApiException('온보딩 완료에 실패했습니다: ${response.statusCode}');
    }
  }

  Future<AuthTokens> refreshToken(String refreshToken) async {
    final request = RefreshTokenRequest(refreshToken: refreshToken);

    final response = await _client.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return AuthTokens.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException('토큰 갱신에 실패했습니다: ${response.statusCode}');
    }
  }

  // 채팅 요청 카운트 조회
  Future<ChatRequestCounts> getChatRequestCounts() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/chat-requests/counts'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return ChatRequestCounts.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException('채팅 요청 카운트 조회에 실패했습니다: ${response.statusCode}');
    }
  }

  // 토큰 정보 조회
  Future<TokenInfo> getTokenInfo() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/tokens/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return TokenInfo.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException('토큰 정보 조회에 실패했습니다: ${response.statusCode}');
    }
  }

  // 매칭 요청
  Future<MatchResponse> requestMatching() async {
    final response = await _client.post(
      Uri.parse('$baseUrl/match/matching'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return MatchResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 402) {
      throw MatchException(
        '만나가 부족합니다. 만나를 충전해주세요.',
        MatchErrorType.insufficientTokens,
      );
    } else if (response.statusCode == 400) {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? '요청에 오류가 있습니다.';

      if (message.contains('성별')) {
        throw MatchException('성별 정보가 설정되지 않았습니다.', MatchErrorType.genderNotSet);
      } else if (message.contains('계정') || message.contains('비활성')) {
        throw MatchException('계정이 비활성화되었습니다.', MatchErrorType.accountInactive);
      } else {
        throw MatchException(message, MatchErrorType.badRequest);
      }
    } else if (response.statusCode == 404) {
      throw MatchException('현재 매칭 가능한 후보가 없습니다.', MatchErrorType.noCandidates);
    } else {
      throw ApiException('매칭 요청에 실패했습니다: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

// 매칭 에러 타입
enum MatchErrorType {
  insufficientTokens,
  genderNotSet,
  accountInactive,
  noCandidates,
  badRequest,
}

// 매칭 관련 예외
class MatchException implements Exception {
  final String message;
  final MatchErrorType errorType;

  MatchException(this.message, this.errorType);

  @override
  String toString() => 'MatchException: $message';
}
