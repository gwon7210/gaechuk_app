import 'package:flutter/material.dart';
import '../../widgets/progress_indicator.dart';

class NicknamePage extends StatefulWidget {
  final Function(String nickname) onNext;
  final VoidCallback onBack;
  final String? initialNickname;

  const NicknamePage({
    super.key,
    required this.onNext,
    required this.onBack,
    this.initialNickname,
  });

  @override
  State<NicknamePage> createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    _nicknameController.text = widget.initialNickname ?? '';
    _nicknameController.addListener(_checkFormValidity);

    _checkFormValidity();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    setState(() {
      final text = _nicknameController.text.trim();
      _isButtonEnabled = text.length >= 2 && text.length <= 20;
    });
  }

  String? _validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '닉네임을 입력해주세요';
    }
    if (value.trim().length < 2) {
      return '닉네임은 2자 이상으로 입력해주세요';
    }
    if (value.trim().length > 20) {
      return '닉네임은 20자 이하로 입력해주세요';
    }
    return null;
  }

  void _handleNext() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onNext(_nicknameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('닉네임 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행상황 표시
            const OnboardingProgressIndicator(currentStep: 2, totalSteps: 3),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 및 설명
                      Text(
                        '어떻게 불러드릴까요?',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '다른 사용자들에게 보여질\n닉네임을 설정해주세요',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 닉네임 입력
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '닉네임',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nicknameController,
                            validator: _validateNickname,
                            maxLength: 20,
                            decoration: InputDecoration(
                              hintText: '예: 믿음이',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 16,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF38BDF8),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEF4444),
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEF4444),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              counterText: '',
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _isButtonEnabled
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                size: 16,
                                color:
                                    _isButtonEnabled
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '2-20자 사이로 입력해주세요',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      _isButtonEnabled
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // 닉네임 가이드라인
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFBAE6FD),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline,
                                  color: Color(0xFF0284C7),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '닉네임 가이드라인',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '• 다른 사용자들이 기억하기 쉬운 이름을 선택해주세요\n'
                              '• 본명이 아닌 별명이나 애칭도 좋습니다\n'
                              '• 부적절한 표현은 사용하지 말아주세요',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF0369A1),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 다음 버튼
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isButtonEnabled
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFFE2E8F0),
                    foregroundColor:
                        _isButtonEnabled
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                  ),
                  child: const Text(
                    '다음',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
