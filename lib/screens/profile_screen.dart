import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userFuture;
  final ApiService _apiService = ApiService();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _userFuture = _apiService.getMe();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isUploading = true);
        await _apiService.uploadProfileImage(File(image.path));
        setState(() {
          _userFuture = _apiService.getMe();
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 이미지 업로드 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '프로필',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await _authService.logout();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
                  );
                }
              }
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(
                color: Color(0xFF7BA7F7),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isUploading) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('사용자 정보를 불러오지 못했습니다.'));
          }
          final user = snapshot.data!;
          String? imageUrl = user['profile_image_url'];
          if (imageUrl != null &&
              imageUrl.isNotEmpty &&
              imageUrl.startsWith('/')) {
            imageUrl = ApiService.baseUrl + imageUrl;
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Stack(
                  children: [
                    imageUrl != null && imageUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFFB3C7F7),
                            backgroundImage: NetworkImage(imageUrl),
                          )
                        : const CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(0xFFB3C7F7),
                            child: Icon(Icons.person,
                                size: 48, color: Colors.white),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Color(0xFFB3C7F7), width: 2),
                          ),
                          child: const Icon(Icons.edit,
                              size: 18, color: Color(0xFF7BA7F7)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user['nickname'] ?? '-',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '신앙고백',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7BA7F7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user['faith_confession'] ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF23233A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 로그아웃 기능 구현
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
