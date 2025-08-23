import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../main.dart';
import 'onboarding/church_info_page.dart';
import 'onboarding/nickname_page.dart';
import 'onboarding/faith_confession_page.dart';

class OnboardingFlowPage extends StatefulWidget {
  const OnboardingFlowPage({super.key});

  @override
  State<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends State<OnboardingFlowPage> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  // 온보딩 데이터
  String? _churchName;
  String? _denomination;
  String? _pastorName;
  String? _nickname;
  String? _faithConfession;

  // 온보딩 완료 상태
  bool _isOnboardingComplete = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPageIndex < 2) {
      setState(() {
        _currentPageIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handleChurchInfo(
    String churchName,
    String denomination,
    String pastorName,
  ) {
    setState(() {
      _churchName = churchName;
      _denomination = denomination;
      _pastorName = pastorName;
    });
    _goToNextPage();
  }

  void _handleNickname(String nickname) {
    setState(() {
      _nickname = nickname;
    });
    _goToNextPage();
  }

  Future<void> _handleFaithConfession(String faithConfession) async {
    setState(() {
      _faithConfession = faithConfession;
    });

    try {
      // 온보딩 데이터 생성
      final onboardingData = OnboardingData(
        church: ChurchInfo(
          churchName: _churchName!,
          denomination: _denomination!,
          pastorName: _pastorName!,
        ),
        nickname: _nickname!,
        faithConfession: faithConfession,
      );

      // 온보딩 완료 API 호출
      final authService = context.read<AuthService>();
      await authService.completeOnboarding(onboardingData);

      // 성공 시 온보딩 완료 상태로 설정
      if (mounted) {
        setState(() {
          _isOnboardingComplete = true;
        });

        // 잠시 대기 후 메인 앱으로 이동
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          // 메인 앱으로 이동 (온보딩 페이지를 모두 제거)
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AppWrapper()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('오류가 발생했습니다'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 온보딩이 완료되면 로딩 화면 표시
    if (_isOnboardingComplete) {
      return Scaffold(
        body: Container(
          color: Colors.white,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                ),
                SizedBox(height: 24),
                Text(
                  '가입 신청이 완료되었습니다!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '잠시 후 메인 화면으로 이동합니다.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
      children: [
        // 1단계: 교회 정보
        ChurchInfoPage(
          onNext: _handleChurchInfo,
          initialChurchName: _churchName,
          initialDenomination: _denomination,
          initialPastorName: _pastorName,
        ),

        // 2단계: 닉네임 설정
        NicknamePage(
          onNext: _handleNickname,
          onBack: _goToPreviousPage,
          initialNickname: _nickname,
        ),

        // 3단계: 신앙 고백
        FaithConfessionPage(
          onComplete: _handleFaithConfession,
          onBack: _goToPreviousPage,
          initialFaithConfession: _faithConfession,
        ),
      ],
    );
  }
}
