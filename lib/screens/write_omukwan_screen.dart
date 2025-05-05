import 'package:flutter/material.dart';

class WriteOmukwanScreen extends StatefulWidget {
  const WriteOmukwanScreen({Key? key}) : super(key: key);

  @override
  State<WriteOmukwanScreen> createState() => _WriteOmukwanScreenState();
}

class _WriteOmukwanScreenState extends State<WriteOmukwanScreen> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
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
            onPressed: () {
              // TODO: 오묵완 저장 로직 구현
              Navigator.pop(context);
            },
            child: const Text(
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
      body: SafeArea(
        child: SingleChildScrollView(
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFB3C7F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '오묵완',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B4B5B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
