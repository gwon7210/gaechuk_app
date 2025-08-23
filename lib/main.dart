import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'models/auth_models.dart';
import 'pages/onboarding_flow_page.dart';
import 'pages/status/pending_review_page.dart';
import 'pages/main_page.dart';
import 'pages/status/rejected_page.dart';

void main() {
  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '72eedb68121a9d2013a7682e57c06457', // 네이티브 앱 키
    javaScriptAppKey: '9a3b3bbf5c1c69001b347fd19e27ca6c', // JavaScript 앱 키
  );

  runApp(const GaechukApp());
}

class GaechukApp extends StatelessWidget {
  const GaechukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: '개척교회 청년들',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {'/': (context) => const AppWrapper()},
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Pretendard',
          scaffoldBackgroundColor: Colors.white,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF38BDF8),
            secondary: Color(0xFF94A3B8),
            surface: Colors.white,
            onSurface: Color(0xFF0F172A),
            onPrimary: Colors.white,
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              height: 1.25,
              letterSpacing: -0.5,
            ),
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              height: 1.35,
              letterSpacing: -0.2,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF334155),
              height: 1.6,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: Color(0xFF0F172A),
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // AuthService 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // 초기화되지 않았으면 로딩 화면
        if (!authService.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 로그인되지 않았으면 로그인 페이지
        if (!authService.isLoggedIn) {
          return const LoginPage();
        }

        // 로그인되었으면 사용자 상태에 따라 분기
        return _buildPageForUserStatus(authService.userStatus);
      },
    );
  }

  Widget _buildPageForUserStatus(UserStatusType? status) {
    switch (status) {
      case UserStatusType.registeredDraft:
        return const OnboardingFlowPage();
      case UserStatusType.pendingReview:
        return PendingReviewPage(
          onLogout: () => context.read<AuthService>().logout(),
        );
      case UserStatusType.verified:
        return MainPage(onLogout: () => context.read<AuthService>().logout());
      case UserStatusType.rejected:
        return RejectedPage(
          onLogout: () => context.read<AuthService>().logout(),
          onRetry: () {
            // 다시 온보딩으로 이동
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OnboardingFlowPage(),
              ),
            );
          },
        );
      default:
        return const OnboardingFlowPage();
    }
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // 상단 여백
              const SizedBox(height: 80),

              // 타이틀 영역 (모던/심플)
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // 앱 이름
                    Text(
                      '개척교회 청년들',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // 중간 여백 및 일러스트 영역
              Expanded(
                flex: 1,
                child: Center(
                  child: SizedBox(
                    width: 240,
                    height: 180,
                    child: Image.asset(
                      'assets/images/couple.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: const Color(0xFF38BDF8).withOpacity(0.35),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // 로그인 버튼 영역
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 카카오 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // 카카오 로그인 로직 구현
                          _handleKakaoLogin(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE500),
                          foregroundColor: const Color(0xFF3C1E1E),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 카카오 아이콘
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3C1E1E),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'K',
                                  style: TextStyle(
                                    color: Color(0xFFFEE500),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '카카오로 시작하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 서비스 약관 텍스트
                    Text(
                      '로그인 시 서비스 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: const Color(0xFFA0AEC0),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleKakaoLogin(BuildContext context) async {
    try {
      await context.read<AuthService>().loginWithKakao();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '로그인에 실패했습니다: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}
