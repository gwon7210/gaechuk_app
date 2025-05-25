import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'dart:io';
import '../config/env.dart';

class ApiService {
  static String get baseUrl => Env.baseUrl;
  final AuthService _authService = AuthService();
  bool _isInitialized = false;
  Future<void>? _initFuture;

  Future<void> _ensureInitialized() {
    _initFuture ??= _authService.init().then((_) => _isInitialized = true);
    return _initFuture!;
  }

  Map<String, String> get _headers {
    if (!_isInitialized) {
      throw Exception('ApiService가 초기화되지 않았습니다.');
    }
    final token = _authService.getToken();
    print('[_headers] token: $token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _logRequest(
      String method, String url, Map<String, String> headers, String? body) {
    final requestLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'REQUEST',
      'method': method,
      'url': url,
      'headers': headers,
      if (body != null) 'body': json.decode(body),
    };
    print('=== API Request ===');
    print(const JsonEncoder.withIndent('  ').convert(requestLog));
    print('==================');
  }

  void _logResponse(http.Response response) {
    final responseLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'RESPONSE',
      'statusCode': response.statusCode,
      'headers': response.headers,
      'body': response.body.isNotEmpty ? json.decode(response.body) : null,
    };
    print('=== API Response ===');
    print(const JsonEncoder.withIndent('  ').convert(responseLog));
    print('===================');
  }

  Future<Map<String, dynamic>> login(
      String phoneNumber, String password) async {
    await _ensureInitialized();
    final url = '$baseUrl/auth/login';
    final body = json.encode({
      'phone_number': phoneNumber,
      'password': password,
    });

    _logRequest('POST', url, _headers, body);

    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: body,
    );

    _logResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('로그인에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> signup({
    required String phoneNumber,
    required String password,
    required String nickname,
    String? churchName,
    String? faithConfession,
  }) async {
    await _ensureInitialized();
    final url = '$baseUrl/users';
    final body = json.encode({
      'phone_number': phoneNumber,
      'password': password,
      'nickname': nickname,
      if (churchName != null) 'church_name': churchName,
      if (faithConfession != null) 'faith_confession': faithConfession,
    });

    _logRequest('POST', url, _headers, body);

    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: body,
    );

    _logResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('회원가입에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> post(String path,
      {required Map<String, dynamic> body}) async {
    await _ensureInitialized();
    final url = '$baseUrl$path';
    final bodyStr = json.encode(body);

    _logRequest('POST', url, _headers, bodyStr);

    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: bodyStr,
    );

    _logResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('요청에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> postWithImage(
    String path, {
    required Map<String, dynamic> fields,
    required Map<String, http.MultipartFile> files,
  }) async {
    await _ensureInitialized();
    final url = '$baseUrl$path';
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll(_headers);
    request.headers.remove('Content-Type');

    fields.forEach((key, value) {
      if (value is bool) {
        request.fields[key] = value.toString().toLowerCase();
      } else {
        request.fields[key] = value.toString();
      }
    });

    files.forEach((key, file) {
      request.files.add(file);
    });

    _logRequest('POST', url, request.headers, json.encode(fields));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _logResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('요청에 실패했습니다.');
    }
  }

  Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParameters}) async {
    await _ensureInitialized();
    final url = Uri.parse('$baseUrl$endpoint')
        .replace(queryParameters: queryParameters);

    _logRequest('GET', url.toString(), _headers, null);

    final response = await http.get(
      url,
      headers: _headers,
    );

    _logResponse(response);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('요청에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> getPosts({
    String? cursor,
    int limit = 10,
    String? postType,
  }) async {
    await _ensureInitialized();
    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
      if (postType != null) 'post_type': postType,
    };

    print('Calling getPosts with params: $queryParams');
    return await get('/posts', queryParameters: queryParams)
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    await _ensureInitialized();
    return await get('/users/me') as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    await _ensureInitialized();
    final url = '$baseUrl/users/profile-image';
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_headers);
    request.headers.remove('Content-Type');
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    _logResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('프로필 이미지 업로드 실패: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint,
      {Map<String, String>? queryParams}) async {
    await _ensureInitialized();
    final url =
        Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

    _logRequest('DELETE', url.toString(), _headers, null);

    final response = await http.delete(
      url,
      headers: _headers,
    );

    _logResponse(response);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return response.body.isEmpty ? {} : json.decode(response.body);
    } else {
      throw Exception('요청에 실패했습니다.');
    }
  }

  Future<void> likePost(String postId) async {
    await _ensureInitialized();
    await post('/likes/posts/$postId', body: {});
  }

  Future<void> unlikePost(String postId) async {
    await _ensureInitialized();
    await delete('/likes/posts/$postId');
  }

  Future<List<dynamic>> getComments(String postId) async {
    await _ensureInitialized();
    final response = await get('/posts/$postId/comments');
    if (response is List) {
      return response;
    } else if (response is Map && response['comments'] is List) {
      return response['comments'];
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> createComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    await _ensureInitialized();
    final body = {
      'postId': postId,
      'content': content,
      if (parentId != null) 'parentId': parentId,
    };
    return post('/comments', body: body);
  }

  Future<void> deleteComment(String commentId) async {
    await _ensureInitialized();
    await delete('/comments/$commentId');
  }

  Future<Map<String, dynamic>> getMyOmokwanCountByMonth(
      int year, int month) async {
    await _ensureInitialized();
    final response =
        await get('/posts/my-omokwan-count-by-month?year=$year&month=$month');
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMyOmokwanByDate(DateTime date) async {
    await _ensureInitialized();
    final response =
        await get('/posts/my-omokwan-by-date?date=${date.toIso8601String()}');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    await _ensureInitialized();
    final url = '$baseUrl/notifications';

    _logRequest('GET', url, _headers, null);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      _logResponse(response);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to get notifications');
      }
    } catch (e) {
      print('Failed to get notifications: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(
      String notificationId) async {
    await _ensureInitialized();
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      print('Failed to mark notification as read: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPost(String postId) async {
    await _ensureInitialized();
    final url = '$baseUrl/posts/$postId';

    _logRequest('GET', url, _headers, null);

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    _logResponse(response);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get post');
    }
  }

  Future<Map<String, dynamic>> searchPosts({
    required String keyword,
    String? cursor,
    int limit = 10,
  }) async {
    await _ensureInitialized();
    final queryParams = {
      'keyword': keyword,
      'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final response = await get('/posts/search', queryParameters: queryParams);
    return response;
  }

  Future<Map<String, dynamic>> getGroups() async {
    final response = await get('/groups');
    return response;
  }

  Future<Map<String, dynamic>> getTodayOmukwans(
      String groupId, String date) async {
    await _ensureInitialized();
    return await get('/groups/$groupId/today-omukwans/$date')
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTodayOmukwanStatus(
      String groupId, String date) async {
    await _ensureInitialized();
    return await get('/groups/$groupId/today-omukwan-status/$date')
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUserTodayOmukwans(
      String groupId, String date, String userId) async {
    await _ensureInitialized();
    return await get('/groups/$groupId/today-omukwans/$date/users/$userId')
        as Map<String, dynamic>;
  }

  // 그룹 멤버 목록 조회
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    await _ensureInitialized();
    final response = await get('/groups/$groupId/members');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> createGroup({
    required String title,
    required String description,
  }) async {
    await _ensureInitialized();
    final body = {
      'title': title,
      'description': description,
    };
    return await post('/groups', body: body);
  }

  Future<Map<String, dynamic>> searchUserByPhone(String phoneNumber) async {
    await _ensureInitialized();
    final response = await get('/users/search/phone/$phoneNumber');
    return response as Map<String, dynamic>;
  }

  Future<void> inviteUserToGroup(String groupId, String phoneNumber) async {
    await _ensureInitialized();
    await post('/groups/$groupId/invite', body: {
      'phone_number': phoneNumber,
    });
  }

  // 다른 API 요청 메서드들을 여기에 추가할 수 있습니다.
  // 예: 메일 목록 조회, 메일 상세 조회 등
}
