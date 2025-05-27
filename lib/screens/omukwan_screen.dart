import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'write_omukwan_screen.dart';
import 'main_home_screen.dart';
import '../services/api_service.dart';
import 'notification_screen.dart';
import 'package:badges/badges.dart' as badges;

class OmukwanScreen extends StatefulWidget {
  const OmukwanScreen({Key? key}) : super(key: key);

  @override
  State<OmukwanScreen> createState() => _OmukwanScreenState();
}

class _OmukwanScreenState extends State<OmukwanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  final ApiService _apiService = ApiService();
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _loadUnreadNotificationCount();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final response = await _apiService.get('/notifications/unread-count');
      setState(() {
        _unreadNotificationCount = response['count'] ?? 0;
      });
    } catch (e) {
      // 무시 또는 필요시 에러 처리
    }
  }

  Widget _buildNotificationIcon() {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: badges.Badge(
        showBadge: _unreadNotificationCount > 0,
        badgeContent: Text(
          _unreadNotificationCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Color(0xFFFF3B30),
          padding: EdgeInsets.all(6),
        ),
        child: IconButton(
          icon: const Icon(Icons.notifications_rounded,
              size: 28, color: Color(0xFF4B4B5B)),
          splashRadius: 24,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
            _loadUnreadNotificationCount();
          },
        ),
      ),
    );
  }

  void _showOmukwanInfoModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation1, animation2, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation1,
          curve: Curves.easeOut,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity:
                Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7BA7F7).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFF7BA7F7),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              '오묵완이란?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1E).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF1C1C1E),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '오묵완은 \'오늘의 묵상 완료\'의 줄임말이에요.\n매일 말씀을 읽고 묵상하면서, 받은 은혜를 함께 나누는 커뮤니티예요.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1C1C1E),
                        height: 1.6,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '오묵완에서는 매일 오늘의 말씀을 전해드리지만, 정해진 규칙은 없어요.\n각자 읽고 있는 큐티 말씀을 자유롭게 나눠주시면 됩니다.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1C1C1E),
                        height: 1.6,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '그럼, 오늘도 묵상을 완료하러 가볼까요? 🙌',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7BA7F7),
                        height: 1.6,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 임시 말씀 데이터
    const String verseRange = '창세기 1장 1~10절';
    const String verseTitle = '태초에 하나님이';
    const String fullVerse = '''1 태초에 하나님이 천지를 창조하시니라.
2 땅이 혼돈하고 공허하며 흑암이 깊음 위에 있고 하나님의 영은 수면 위에 운행하시니라.
3 하나님이 이르시되 빛이 있으라 하시니 빛이 있었고
4 빛이 하나님이 보시기에 좋았더라 하나님이 빛과 어둠을 나누사
5 하나님이 빛을 낮이라 부르시고 어둠을 밤이라 부르시니라 저녁이 되고 아침이 되니 이는 첫째 날이니라
6 하나님이 이르시되 물 가운데에 궁창이 있어 물과 물로 나뉘라 하시고
7 하나님이 궁창을 만들어 궁창 아래의 물과 궁창 위의 물로 나뉘게 하시니 그대로 되니라
8 하나님이 궁창을 하늘이라 부르시니라 저녁이 되고 아침이 되니 이는 둘째 날이니라
9 하나님이 이르시되 천하의 물이 한 곳으로 모이고 뭍이 드러나라 하시니 그대로 되니라
10 하나님이 뭍을 땅이라 부르시고 모인 물을 바다라 부르시니 하나님이 보시기에 좋았더라''';

    // 현재 날짜와 요일 가져오기
    final now = DateTime.now();
    final dateFormat = DateFormat('M월 d일');
    final weekdayFormat = DateFormat('EEEE', 'ko_KR');
    final formattedDate = dateFormat.format(now);
    final formattedWeekday = weekdayFormat.format(now);

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FF), Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 페이지 제목
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '오',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7BA7F7),
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: '늘의 ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: '묵',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7BA7F7),
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: '상 ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: '완',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7BA7F7),
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: '료',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildNotificationIcon(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 상단 말씀 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 깜빡이는 텍스트
                  Center(
                    child: GestureDetector(
                      onTap: _showOmukwanInfoModal,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7BA7F7).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF7BA7F7).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFF7BA7F7),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '오묵완이 처음이신가요?',
                                style: TextStyle(
                                  color: Color(0xFF7BA7F7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: const Color(0xFF7BA7F7).withOpacity(0.6),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7BA7F7).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7BA7F7).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                verseRange,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7BA7F7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              verseTitle,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              fullVerse.length > 100
                                  ? fullVerse.substring(0, 100) + '...'
                                  : fullVerse,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Color(0xFF23233A),
                                height: 1.6,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FullVerseScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF7BA7F7).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '전체 말씀 보기',
                                      style: TextStyle(
                                        color: Color(0xFF7BA7F7),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFF7BA7F7),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // 오묵완 작성 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7BA7F7).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WriteOmukwanScreen(),
                        ),
                      );

                      if (result == true && context.mounted) {
                        // 나눔 페이지로 이동
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MainHomeScreen(initialIndex: 1),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7BA7F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '오묵완 작성하러 가기',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
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

class FullVerseScreen extends StatefulWidget {
  const FullVerseScreen({Key? key}) : super(key: key);

  @override
  State<FullVerseScreen> createState() => _FullVerseScreenState();
}

class _FullVerseScreenState extends State<FullVerseScreen> {
  double _fontSize = 17.0; // 기본 글자 크기
  final double _minFontSize = 14.0;
  final double _maxFontSize = 24.0;
  final double _fontSizeStep = 1.0;

  void _decreaseFontSize() {
    if (_fontSize > _minFontSize) {
      setState(() {
        _fontSize -= _fontSizeStep;
      });
    }
  }

  void _increaseFontSize() {
    if (_fontSize < _maxFontSize) {
      setState(() {
        _fontSize += _fontSizeStep;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const String verseRange = '창세기 1장 1~10절';
    const String verseTitle = '태초에 하나님이';
    const String fullVerse = '''1 태초에 하나님이 천지를 창조하시니라.
2 땅이 혼돈하고 공허하며 흑암이 깊음 위에 있고 하나님의 영은 수면 위에 운행하시니라.
3 하나님이 이르시되 빛이 있으라 하시니 빛이 있었고
4 빛이 하나님이 보시기에 좋았더라 하나님이 빛과 어둠을 나누사
5 하나님이 빛을 낮이라 부르시고 어둠을 밤이라 부르시니라 저녁이 되고 아침이 되니 이는 첫째 날이니라
6 하나님이 이르시되 물 가운데에 궁창이 있어 물과 물로 나뉘라 하시고
7 하나님이 궁창을 만들어 궁창 아래의 물과 궁창 위의 물로 나뉘게 하시니 그대로 되니라
8 하나님이 궁창을 하늘이라 부르시니라 저녁이 되고 아침이 되니 이는 둘째 날이니라
9 하나님이 이르시되 천하의 물이 한 곳으로 모이고 뭍이 드러나라 하시니 그대로 되니라
10 하나님이 뭍을 땅이라 부르시고 모인 물을 바다라 부르시니 하나님이 보시기에 좋았더라''';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1C1C1E)),
        title: const Text(
          '오늘의 묵상',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Color(0xFF7BA7F7),
              size: 24,
            ),
            onPressed: _decreaseFontSize,
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF7BA7F7),
              size: 24,
            ),
            onPressed: _increaseFontSize,
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7BA7F7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  verseRange,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7BA7F7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                verseTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7BA7F7).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  fullVerse,
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: const Color(0xFF23233A),
                    height: 1.8,
                    letterSpacing: -0.3,
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
