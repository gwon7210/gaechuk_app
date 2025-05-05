import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';
  final AuthService _authService = AuthService();

  Future<void> initialize() async {
    await _authService.init();
  }

  Map<String, String> get _headers {
    final token = _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _logRequest(
      String method, String url, Map<String, String> headers, String? body) {
    print('=== API Request ===');
    print('Method: $method');
    print('URL: $url');
    print('Headers: $headers');
    if (body != null) {
      print('Body: $body');
    }
    print('==================');
  }

  void _logResponse(http.Response response) {
    print('=== API Response ===');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');
    print('===================');
  }

  Future<Map<String, dynamic>> login(
      String phoneNumber, String password) async {
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

  Future<Map<String, dynamic>> post(String path,
      {required Map<String, dynamic> body}) async {
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
    final url = '$baseUrl$path';
    final request = http.MultipartRequest('POST', Uri.parse(url));

    // 헤더 추가
    request.headers.addAll(_headers);
    request.headers
        .remove('Content-Type'); // multipart 요청에서는 Content-Type을 자동으로 설정

    // 필드 추가
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // 파일 추가
    files.forEach((key, file) {
      request.files.add(file);
    });

    _logRequest('POST', url, request.headers, fields.toString());

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _logResponse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('요청에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? queryParams}) async {
    final url =
        Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);

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
    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
      if (postType != null) 'post_type': postType,
    };

    print('Calling getPosts with params: $queryParams');
    return get('/posts', queryParams: queryParams);
  }

  Future<Map<String, dynamic>> getMe() async {
    return get('/users/me');
  }

  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
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

  // 다른 API 요청 메서드들을 여기에 추가할 수 있습니다.
  // 예: 메일 목록 조회, 메일 상세 조회 등
}
