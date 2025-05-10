import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String? nickname;

  const VerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    this.nickname,
  }) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _verificationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _codeSent = false;
  String _verificationId = '';

  String formatPhoneNumber(String input) {
    // 숫자만 남기기
    String digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9 || digits.length > 11) {
      return '';
    }
    // 01012345678 → +821012345678
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return '+82$digits';
  }

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
    _verificationId = widget.verificationId;
  }

  Future<void> _sendCode() async {
    final formatted = formatPhoneNumber(_phoneController.text);
    if (formatted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 휴대폰 번호를 입력해주세요.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formatted,
        codeSent: (verificationId, resendToken) {
          setState(() {
            _codeSent = true;
            _verificationId = verificationId;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('인증번호가 전송되었습니다.')),
            );
          }
        },
        verificationFailed: (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('인증 실패: ${e.message}')),
            );
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('인증번호 입력 시간이 만료되었습니다.')),
            );
          }
        },
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android 자동 인증 시 바로 다음 단계로
          // (여기서는 자동 로그인 방지 위해 아무 처리도 하지 않음)
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증번호 전송 실패: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('6자리 인증번호를 입력해주세요.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _verificationController.text,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      final uid = user?.uid;
      final phone = user?.phoneNumber;
      // 인증 후 즉시 로그아웃
      await _auth.signOut();
      // TODO: 백엔드로 uid, phone 전달 (회원가입/로그인 처리)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 성공! UID: $uid, 전화번호: $phone')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordScreen(
              phoneNumber: _phoneController.text,
              nickname: widget.nickname,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 실패: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignup = widget.nickname != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Color(0xFF007AFF),
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              '휴대폰 번호 인증',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                enabled: isSignup,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.3,
                ),
                decoration: const InputDecoration(
                  hintText: '휴대폰 번호를 입력해주세요',
                  hintStyle: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        '인증번호 받기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (_codeSent) ...[
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _verificationController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.3,
                  ),
                  decoration: const InputDecoration(
                    hintText: '인증번호 6자리를 입력해주세요',
                    hintStyle: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          '확인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                ),
              ),
            ],
            const Spacer(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _verificationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
