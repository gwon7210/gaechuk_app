import 'package:flutter/material.dart';
import '../../widgets/progress_indicator.dart';

class FaithConfessionPage extends StatefulWidget {
  final Function(String faithConfession) onComplete;
  final VoidCallback onBack;
  final String? initialFaithConfession;

  const FaithConfessionPage({
    super.key,
    required this.onComplete,
    required this.onBack,
    this.initialFaithConfession,
  });

  @override
  State<FaithConfessionPage> createState() => _FaithConfessionPageState();
}

class _FaithConfessionPageState extends State<FaithConfessionPage> {
  final _formKey = GlobalKey<FormState>();
  final _faithConfessionController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _faithConfessionController.text = widget.initialFaithConfession ?? '';
    _faithConfessionController.addListener(_checkFormValidity);

    _checkFormValidity();
  }

  @override
  void dispose() {
    _faithConfessionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    setState(() {
      final text = _faithConfessionController.text.trim();
      _isButtonEnabled = text.length >= 50 && text.length <= 600;
    });
  }

  String? _validateFaithConfession(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '신앙 고백을 작성해주세요';
    }
    if (value.trim().length < 50) {
      return '신앙 고백은 50자 이상으로 작성해주세요';
    }
    if (value.trim().length > 600) {
      return '신앙 고백은 600자 이하로 작성해주세요';
    }
    return null;
  }

  Future<void> _handleComplete() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.onComplete(_faithConfessionController.text.trim());
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLength = _faithConfessionController.text.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('신앙 고백'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : widget.onBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행상황 표시
            const OnboardingProgressIndicator(currentStep: 3, totalSteps: 3),

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
                        '신앙 고백을\n들려주세요',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '하나님과의 관계, 신앙의 여정에 대해\n자유롭게 작성해주세요',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 신앙 고백 입력
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '신앙 고백',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '$currentLength/600',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      currentLength >= 50 &&
                                              currentLength <= 600
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _faithConfessionController,
                            focusNode: _focusNode,
                            validator: _validateFaithConfession,
                            maxLines: 8,
                            maxLength: 600,
                            decoration: InputDecoration(
                              hintText:
                                  '예: 저는 예수 그리스트를 구주로 영접하며 하나님의 은혜로 구원받았음을 고백합니다...',
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
                              height: 1.5,
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
                                '50-600자 사이로 작성해주세요',
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
                      const SizedBox(height: 32),

                      // 작성 가이드라인
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
                                  Icons.favorite_outline,
                                  color: Color(0xFF0284C7),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '작성 가이드',
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
                              '• 하나님과의 만남이나 변화의 경험\n'
                              '• 신앙생활에서 중요하게 생각하는 가치\n'
                              '• 앞으로의 신앙적 소망이나 목표\n'
                              '• 진솔하고 개인적인 이야기를 편하게 나눠주세요',
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

            // 완료 버튼
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _isButtonEnabled && !_isLoading ? _handleComplete : null,
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
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            '가입 신청 완료',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
