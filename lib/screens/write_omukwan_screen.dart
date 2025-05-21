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
  final TextEditingController _q1Controller = TextEditingController();
  final TextEditingController _q2Controller = TextEditingController();
  final TextEditingController _q3Controller = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String _visibility = 'public'; // 'public', 'group', 'private' 중 하나
  String _mode = 'free'; // 'free' 또는 'template'

  @override
  void dispose() {
    _contentController.dispose();
    _q1Controller.dispose();
    _q2Controller.dispose();
    _q3Controller.dispose();
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
    if (_mode == 'free' && _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요')),
      );
      return;
    }

    if (_mode == 'template' &&
        (_q1Controller.text.trim().isEmpty ||
            _q2Controller.text.trim().isEmpty ||
            _q3Controller.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 질문에 답변해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fields = {
        'mode': _mode,
        'visibility': _visibility,
        'post_type': '오묵완',
      };

      if (_mode == 'free') {
        fields['content'] = _contentController.text.trim();
      } else {
        fields['q1_answer'] = _q1Controller.text.trim();
        fields['q2_answer'] = _q2Controller.text.trim();
        fields['q3_answer'] = _q3Controller.text.trim();
      }

      if (_selectedImage != null) {
        final file = await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        );

        await _apiService.postWithImage(
          '/posts',
          fields: fields,
          files: {'image': file},
        );
      } else {
        await _apiService.post('/posts', body: fields);
      }

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
            // 모드 선택 버튼
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _mode = 'free'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _mode == 'free'
                          ? const Color(0xFF007AFF)
                          : Colors.grey[200],
                      foregroundColor:
                          _mode == 'free' ? Colors.white : Colors.black,
                    ),
                    child: const Text('자유 묵상'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _mode = 'template'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _mode == 'template'
                          ? const Color(0xFF007AFF)
                          : Colors.grey[200],
                      foregroundColor:
                          _mode == 'template' ? Colors.white : Colors.black,
                    ),
                    child: const Text('템플릿 묵상'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_mode == 'free') ...[
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
            ] else ...[
              _buildTemplateQuestion(
                controller: _q1Controller,
                question: '이 말씀을 통해 알게된 하나님은 누구십니까?',
              ),
              const SizedBox(height: 16),
              _buildTemplateQuestion(
                controller: _q2Controller,
                question: '성령님, 이 말씀을 통하여 저에게 무엇을 말씀하시길 원하십니까?',
              ),
              const SizedBox(height: 16),
              _buildTemplateQuestion(
                controller: _q3Controller,
                question: '성령님, 주신 말씀에 따라 제가 구체적으로 어떻게 하기를 원하십니까?',
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  '공개 설정',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _visibility,
                  items: const [
                    DropdownMenuItem(
                      value: 'public',
                      child: Text('전체 공개'),
                    ),
                    DropdownMenuItem(
                      value: 'group',
                      child: Text('그룹 공개'),
                    ),
                    DropdownMenuItem(
                      value: 'private',
                      child: Text('나만 보기'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _visibility = value;
                      });
                    }
                  },
                ),
              ],
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

  Widget _buildTemplateQuestion({
    required TextEditingController controller,
    required String question,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            maxLines: 5,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.3,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              hintText: '답변을 입력해주세요',
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
      ],
    );
  }
}
