import 'package:flutter/material.dart';
import 'write_post_screen.dart';
import 'write_omukwan_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _categoryIndex = 0;
  int _bottomIndex = 0;
  bool _isWriteMenuOpen = false;
  final List<String> categories = ['전체', '묵상나눔', '기도제목', '신앙고민', '교회추천'];

  // 샘플 게시글 데이터
  final List<Map<String, dynamic>> posts = [
    {
      'profileColor': Colors.blue,
      'nickname': '빈곤그자체',
      'level': 1,
      'time': '2시간 전',
      'category': '묵상나눔',
      'content':
          '유연성이 좋아야 근성장?\n제가 몸이 뻣뻣합니다. 예전에는 스트레칭 자주 해주고 했는데 요즘은 거의 안해서 몸이 많이 뻣뻣합니다. 오늘 제가 며칠전부터 왼쪽 목에 뻣뻣한 느낌이 계속 있어서 불편했는데 운동 다 끝나고 프로선수 지인분에게 마사지 받았습니다. 몸이 많이 뻣뻣하다고 하시더라구요. 몸이....',
      'likes': 0,
      'comments': 5,
      'expanded': false,
    },
    {
      'profileColor': Colors.purple,
      'nickname': '원뜨',
      'level': 1,
      'time': '4시간 전',
      'category': '기도제목',
      'content':
          '휴식없이 웨이트를 계속해서 자극이 무뎌진상태라면 어찌해야합니까?\n제 가슴 자극이없고 근육통도없고 마치된것마냥 느낌이 오는 그 이유가 곰곰히 생각해보니 과거 운동 초보때 2분할을 매일할때 운동량에 욕심내서 부위당 20~25세트씩',
      'likes': 0,
      'comments': 0,
      'expanded': false,
    },
  ];

  Color _categoryColor(String category) {
    switch (category) {
      case '묵상나눔':
        return const Color(0xFFB3C7F7); // 하늘색
      case '기도제목':
        return const Color(0xFFD1B3F7); // 연보라
      case '신앙고민':
        return const Color(0xFFB3F7E0); // 민트
      case '교회추천':
        return const Color(0xFFF7E6B3); // 연노랑
      default:
        return const Color(0xFFF2F2F7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // 카테고리 탭
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, idx) =>
                      _buildCategoryTab(categories[idx], idx),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5EA)),
            // 게시글 리스트
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                itemCount: posts.length,
                itemBuilder: (context, idx) => _buildPostCard(idx),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: Container(
        height: 240,
        width: 72,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            if (_isWriteMenuOpen) ...[
              Positioned(
                bottom: 160,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isWriteMenuOpen ? 1.0 : 0.0,
                  child: FloatingActionButton(
                    heroTag: 'omukwan',
                    onPressed: () {
                      setState(() => _isWriteMenuOpen = false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WriteOmukwanScreen()),
                      );
                    },
                    backgroundColor: const Color(0xFF7BA7F7),
                    child: const Text(
                      '오묵완',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 88,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isWriteMenuOpen ? 1.0 : 0.0,
                  child: FloatingActionButton(
                    heroTag: 'post',
                    onPressed: () {
                      setState(() => _isWriteMenuOpen = false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WritePostScreen()),
                      );
                    },
                    backgroundColor: const Color(0xFF7BA7F7),
                    child: const Text(
                      '게시글',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Positioned(
              bottom: 0,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _isWriteMenuOpen ? 0.125 : 0,
                child: FloatingActionButton(
                  heroTag: 'toggle',
                  onPressed: () {
                    setState(() => _isWriteMenuOpen = !_isWriteMenuOpen);
                  },
                  backgroundColor: const Color(0xFF7BA7F7),
                  child: Icon(
                    _isWriteMenuOpen ? Icons.close : Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String label, int index) {
    final bool selected = _categoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _categoryIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7BA7F7) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0x227BA7F7),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF8E8E93),
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(int idx) {
    final post = posts[idx];
    final bool expanded = post['expanded'] as bool;
    final String content = post['content'] as String;
    final lines = content.split('\n');
    final preview = lines.take(3).join('\n');
    final isLong = lines.length > 3;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      elevation: 2,
      color: Colors.white,
      shadowColor: const Color(0x1A7BA7F7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: post['profileColor'],
                  child: const Icon(Icons.person, color: Colors.white),
                  radius: 20,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['nickname'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5,
                        color: Color(0xFF3A3A4A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '레벨 ${post['level']}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF7BA7F7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  post['time'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB0B3B8),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _categoryColor(post['category']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post['category'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4B4B5B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              expanded ? content : preview,
              maxLines: expanded ? null : 3,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15.5,
                color: Color(0xFF23233A),
                height: 1.7,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
              ),
            ),
            if (isLong && !expanded)
              GestureDetector(
                onTap: () => setState(() => posts[idx]['expanded'] = true),
                child: const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    '더보기',
                    style: TextStyle(
                      color: Color(0xFF7BA7F7),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(Icons.favorite_border, size: 20, color: Color(0xFFB0B3B8)),
                const SizedBox(width: 5),
                Text(
                  '${post['likes']}',
                  style: const TextStyle(
                    color: Color(0xFFB0B3B8),
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(width: 18),
                Icon(
                  Icons.mode_comment_outlined,
                  size: 20,
                  color: Color(0xFFB0B3B8),
                ),
                const SizedBox(width: 5),
                Text(
                  '${post['comments']}',
                  style: const TextStyle(
                    color: Color(0xFFB0B3B8),
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF7BA7F7),
      unselectedItemColor: const Color(0xFFB0B3B8),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      iconSize: 26,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.groups), label: '소셜'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: '소모임'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
      ],
      currentIndex: _bottomIndex,
      onTap: (idx) => setState(() => _bottomIndex = idx),
      elevation: 8,
    );
  }
}
