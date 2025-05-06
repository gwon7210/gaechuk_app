import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class WriteOmukwanScreen extends StatefulWidget {
  const WriteOmukwanScreen({Key? key}) : super(key: key);

  @override
  State<WriteOmukwanScreen> createState() => _WriteOmukwanScreenState();
}

class _WriteOmukwanScreenState extends State<WriteOmukwanScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 선택하는데 실패했습니다: $e')),
      );
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fields = {
        'content': _contentController.text.trim(),
        'post_type': '오목완',
      };
      final files = <String, http.MultipartFile>{};

      if (_selectedImage != null) {
        files['image'] =
            await http.MultipartFile.fromPath('image', _selectedImage!.path);
      }

      await _apiService.postWithImage(
        '/posts',
        fields: fields,
        files: files,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Color(0xFF007AFF),
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '오묵완 작성',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                    ),
                  )
                : const Text(
                    '완료',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 15,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.3,
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  hintText: '오늘 말씀은 어땠나요?',
                  hintStyle: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF007AFF),
                    size: 24,
                  ),
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
