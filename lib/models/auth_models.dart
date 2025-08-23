import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);
}

@JsonSerializable()
class UserStatus {
  final String status;

  UserStatus({required this.status});

  factory UserStatus.fromJson(Map<String, dynamic> json) =>
      _$UserStatusFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatusToJson(this);
}

enum UserStatusType {
  @JsonValue('REGISTERED_DRAFT')
  registeredDraft,
  @JsonValue('PENDING_REVIEW')
  pendingReview,
  @JsonValue('VERIFIED')
  verified,
  @JsonValue('REJECTED')
  rejected,
}

@JsonSerializable()
class ChurchInfo {
  final String churchName;
  final String denomination;
  final String pastorName;

  ChurchInfo({
    required this.churchName,
    required this.denomination,
    required this.pastorName,
  });

  factory ChurchInfo.fromJson(Map<String, dynamic> json) =>
      _$ChurchInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ChurchInfoToJson(this);
}

@JsonSerializable()
class OnboardingData {
  final ChurchInfo church;
  final String nickname;
  final String faithConfession;

  OnboardingData({
    required this.church,
    required this.nickname,
    required this.faithConfession,
  });

  factory OnboardingData.fromJson(Map<String, dynamic> json) =>
      _$OnboardingDataFromJson(json);
  Map<String, dynamic> toJson() => _$OnboardingDataToJson(this);
}

@JsonSerializable()
class KakaoLoginRequest {
  final String accessToken;
  final String? mockKakaoId;
  final String? gender;
  final String? birthdate;
  final String? phone;

  KakaoLoginRequest({
    required this.accessToken,
    this.mockKakaoId,
    this.gender,
    this.birthdate,
    this.phone,
  });

  factory KakaoLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$KakaoLoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$KakaoLoginRequestToJson(this);
}

@JsonSerializable()
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

// 채팅 요청 카운트 모델
@JsonSerializable()
class ChatRequestCounts {
  final int incomingCount;
  final int outgoingCount;

  ChatRequestCounts({required this.incomingCount, required this.outgoingCount});

  factory ChatRequestCounts.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestCountsFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRequestCountsToJson(this);
}

// 토큰 정보 모델
@JsonSerializable()
class TokenInfo {
  final String userId;
  final int tokenCount;
  final String updatedAt;

  TokenInfo({
    required this.userId,
    required this.tokenCount,
    required this.updatedAt,
  });

  factory TokenInfo.fromJson(Map<String, dynamic> json) =>
      _$TokenInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TokenInfoToJson(this);
}

// 매칭 후보자 모델
@JsonSerializable()
class MatchCandidate {
  final String id;
  final String nickname;
  final int age;

  MatchCandidate({required this.id, required this.nickname, required this.age});

  factory MatchCandidate.fromJson(Map<String, dynamic> json) =>
      _$MatchCandidateFromJson(json);
  Map<String, dynamic> toJson() => _$MatchCandidateToJson(this);
}

// 매칭 응답 모델
@JsonSerializable()
class MatchResponse {
  final List<MatchCandidate> candidates;

  MatchResponse({required this.candidates});

  factory MatchResponse.fromJson(Map<String, dynamic> json) =>
      _$MatchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MatchResponseToJson(this);
}
