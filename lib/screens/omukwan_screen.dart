import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'write_omukwan_screen.dart';
import 'main_home_screen.dart';

class OmukwanScreen extends StatelessWidget {
  const OmukwanScreen({Key? key}) : super(key: key);

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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FF), Colors.white],
        ),
      ),
      child: Column(
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
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF1C1C1E),
                    size: 28,
                  ),
                  onPressed: () {},
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [],
                ),
                const SizedBox(height: 16),
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
                                  builder: (context) => const FullVerseScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7BA7F7).withOpacity(0.1),
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
                      // 소셜 페이지로 이동
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
          const Expanded(
            child: SizedBox(),
          ),
        ],
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
