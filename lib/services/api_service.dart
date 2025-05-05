import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';
  final AuthService _authService = AuthService();

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

  // 다른 API 요청 메서드들을 여기에 추가할 수 있습니다.
  // 예: 메일 목록 조회, 메일 상세 조회 등
}
