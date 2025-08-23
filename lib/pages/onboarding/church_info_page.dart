import 'package:flutter/material.dart';
import '../../widgets/progress_indicator.dart';

class ChurchInfoPage extends StatefulWidget {
  final Function(String churchName, String denomination, String pastorName)
  onNext;
  final String? initialChurchName;
  final String? initialDenomination;
  final String? initialPastorName;

  const ChurchInfoPage({
    super.key,
    required this.onNext,
    this.initialChurchName,
    this.initialDenomination,
    this.initialPastorName,
  });

  @override
  State<ChurchInfoPage> createState() => _ChurchInfoPageState();
}

class _ChurchInfoPageState extends State<ChurchInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _churchNameController = TextEditingController();
  final _denominationController = TextEditingController();
  final _pastorNameController = TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    _churchNameController.text = widget.initialChurchName ?? '';
    _denominationController.text = widget.initialDenomination ?? '';
    _pastorNameController.text = widget.initialPastorName ?? '';

    _churchNameController.addListener(_checkFormValidity);
    _denominationController.addListener(_checkFormValidity);
    _pastorNameController.addListener(_checkFormValidity);

    _checkFormValidity();
  }

  @override
  void dispose() {
    _churchNameController.dispose();
    _denominationController.dispose();
    _pastorNameController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    setState(() {
      _isButtonEnabled =
          _churchNameController.text.trim().isNotEmpty &&
          _denominationController.text.trim().isNotEmpty &&
          _pastorNameController.text.trim().isNotEmpty;
    });
  }

  String? _validateChurchName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '교회명을 입력해주세요';
    }
    if (value.trim().length > 120) {
      return '교회명은 120자 이하로 입력해주세요';
    }
    return null;
  }

  String? _validateDenomination(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '교단을 입력해주세요';
    }
    if (value.trim().length > 80) {
      return '교단은 80자 이하로 입력해주세요';
    }
    return null;
  }

  String? _validatePastorName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '담임목사님 성함을 입력해주세요';
    }
    if (value.trim().length > 80) {
      return '담임목사님 성함은 80자 이하로 입력해주세요';
    }
    return null;
  }

  void _handleNext() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onNext(
        _churchNameController.text.trim(),
        _denominationController.text.trim(),
        _pastorNameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('교회 정보'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행상황 표시
            const OnboardingProgressIndicator(currentStep: 1, totalSteps: 3),

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
                        '소속 교회 정보를\n알려주세요',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '믿음의 공동체에서 함께하기 위해\n교회 정보가 필요해요',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 교회명 입력
                      _buildInputField(
                        controller: _churchNameController,
                        label: '교회명',
                        hintText: '예: 새로운교회',
                        validator: _validateChurchName,
                      ),
                      const SizedBox(height: 24),

                      // 교단 입력
                      _buildInputField(
                        controller: _denominationController,
                        label: '교단',
                        hintText: '예: 장로교',
                        validator: _validateDenomination,
                      ),
                      const SizedBox(height: 24),

                      // 담임목사 입력
                      _buildInputField(
                        controller: _pastorNameController,
                        label: '담임목사님 성함',
                        hintText: '예: 김목사',
                        validator: _validatePastorName,
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }
}
