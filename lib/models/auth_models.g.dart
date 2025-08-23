// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => AuthTokens(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$AuthTokensToJson(AuthTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

UserStatus _$UserStatusFromJson(Map<String, dynamic> json) =>
    UserStatus(status: json['status'] as String);

Map<String, dynamic> _$UserStatusToJson(UserStatus instance) =>
    <String, dynamic>{'status': instance.status};

ChurchInfo _$ChurchInfoFromJson(Map<String, dynamic> json) => ChurchInfo(
  churchName: json['churchName'] as String,
  denomination: json['denomination'] as String,
  pastorName: json['pastorName'] as String,
);

Map<String, dynamic> _$ChurchInfoToJson(ChurchInfo instance) =>
    <String, dynamic>{
      'churchName': instance.churchName,
      'denomination': instance.denomination,
      'pastorName': instance.pastorName,
    };

OnboardingData _$OnboardingDataFromJson(Map<String, dynamic> json) =>
    OnboardingData(
      church: ChurchInfo.fromJson(json['church'] as Map<String, dynamic>),
      nickname: json['nickname'] as String,
      faithConfession: json['faithConfession'] as String,
    );

Map<String, dynamic> _$OnboardingDataToJson(OnboardingData instance) =>
    <String, dynamic>{
      'church': instance.church,
      'nickname': instance.nickname,
      'faithConfession': instance.faithConfession,
    };

KakaoLoginRequest _$KakaoLoginRequestFromJson(Map<String, dynamic> json) =>
    KakaoLoginRequest(
      accessToken: json['accessToken'] as String,
      mockKakaoId: json['mockKakaoId'] as String?,
      gender: json['gender'] as String?,
      birthdate: json['birthdate'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$KakaoLoginRequestToJson(KakaoLoginRequest instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'mockKakaoId': instance.mockKakaoId,
      'gender': instance.gender,
      'birthdate': instance.birthdate,
      'phone': instance.phone,
    };

RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) =>
    RefreshTokenRequest(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshTokenRequestToJson(
  RefreshTokenRequest instance,
) => <String, dynamic>{'refreshToken': instance.refreshToken};

ChatRequestCounts _$ChatRequestCountsFromJson(Map<String, dynamic> json) =>
    ChatRequestCounts(
      incomingCount: (json['incomingCount'] as num).toInt(),
      outgoingCount: (json['outgoingCount'] as num).toInt(),
    );

Map<String, dynamic> _$ChatRequestCountsToJson(ChatRequestCounts instance) =>
    <String, dynamic>{
      'incomingCount': instance.incomingCount,
      'outgoingCount': instance.outgoingCount,
    };

TokenInfo _$TokenInfoFromJson(Map<String, dynamic> json) => TokenInfo(
  userId: json['userId'] as String,
  tokenCount: (json['tokenCount'] as num).toInt(),
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$TokenInfoToJson(TokenInfo instance) => <String, dynamic>{
  'userId': instance.userId,
  'tokenCount': instance.tokenCount,
  'updatedAt': instance.updatedAt,
};

MatchCandidate _$MatchCandidateFromJson(Map<String, dynamic> json) =>
    MatchCandidate(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      age: (json['age'] as num).toInt(),
    );

Map<String, dynamic> _$MatchCandidateToJson(MatchCandidate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'age': instance.age,
    };

MatchResponse _$MatchResponseFromJson(Map<String, dynamic> json) =>
    MatchResponse(
      candidates:
          (json['candidates'] as List<dynamic>)
              .map((e) => MatchCandidate.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$MatchResponseToJson(MatchResponse instance) =>
    <String, dynamic>{'candidates': instance.candidates};
