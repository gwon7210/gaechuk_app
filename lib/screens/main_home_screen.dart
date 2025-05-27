import 'package:flutter/material.dart';
import 'write_post_screen.dart';
import 'write_omukwan_screen.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'profile_screen.dart';
import 'post_detail_screen.dart';
import 'notification_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'search_screen.dart';
import 'package:lottie/lottie.dart';
import 'omukwan_screen.dart';
import '../config/env.dart';
import 'group/group_list_screen.dart';

class MainHomeScreen extends StatefulWidget {
  final int initialIndex;
  const MainHomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen>
    with SingleTickerProviderStateMixin {
  int _categoryIndex = 0;
  int _bottomIndex = 0;
  bool _isWriteMenuOpen = false;
  final List<String> categories = ['전체', '오묵완', '말씀나눔', '기도제목', '고민', '교회추천'];
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  DateTime? _lastApiCallTime;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  bool _isScrolling = false;
  Timer? _scrollEndTimer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  List<Map<String, dynamic>> posts = [];
  List<double> likeScales = [];
  bool isLoading = false;
  String? lastCursor;
  bool hasMore = true;
  int _unreadNotificationCount = 0;

  final Map<String, IconData> categoryIcons = {
    '전체': Icons.apps,
    '오묵완': Icons.emoji_events,
    '말씀나눔': Icons.menu_book,
    '기도제목': Icons.self_improvement,
    '고민': Icons.psychology_alt,
    '교회추천': Icons.church,
  };

  @override
  void initState() {
    super.initState();
    _bottomIndex = widget.initialIndex;
    _scrollController.addListener(_onScroll);
    _loadPosts();
    _loadUnreadNotificationCount();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollEndTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoading && hasMore) {
        _scrollEndTimer?.cancel();
        _scrollEndTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            _loadPosts();
          }
        });
      }
    }
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (isLoading || (!refresh && !hasMore)) return;

    setState(() {
      isLoading = true;
      if (refresh) {
        lastCursor = null;
        posts = [];
        hasMore = true;
        likeScales = [];
      }
    });

    // 로딩 상태를 좀 더 오래 보여주기 위한 지연
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      print(
          'Attempting to load posts - Cursor: $lastCursor, Category: ${_categoryIndex == 0 ? 'all' : categories[_categoryIndex]}');

      final response = await _apiService.getPosts(
        cursor: lastCursor,
        limit: 3,
        postType: _categoryIndex == 0 ? null : categories[_categoryIndex],
      );

      if (!mounted) return;

      print('Posts loaded successfully: ${response.toString()}');

      try {
        print('API Response: $response');
        final List<dynamic> newPosts = response['posts'];
        final Map<String, dynamic> meta = response['meta'];

        final processedPosts = newPosts.map((post) {
          final user = post['user'] ?? {};
          return {
            'id': post['id'],
            'profileColor': Colors.blue,
            'nickname': user['nickname'] ?? '',
            'profile_image_url': user['profile_image_url'],
            'time': _formatTime(post['created_at']),
            'category': post['post_type'] ?? '',
            'content': post['content'] ?? '',
            'comments': post['comments_count']?.toString() ?? '0',
            'expanded': false,
            'image_url': post['image_url'],
            'liked_by_me': post['liked_by_me'] ?? false,
            'likes_count': post['likes_count'] ?? 0,
            'mode': post['mode'],
            'q1_answer': post['q1_answer'],
            'q2_answer': post['q2_answer'],
            'q3_answer': post['q3_answer'],
          };
        }).toList();

        if (!mounted) return;

        setState(() {
          posts.addAll(processedPosts);
          lastCursor = meta['nextCursor'];
          hasMore = meta['hasNextPage'] ?? false;
          isLoading = false;
          likeScales.addAll(List.filled(processedPosts.length, 1.0));
        });
      } catch (e, stackTrace) {
        print('Error processing posts: $e');
        print('Stack trace: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('게시물을 불러오는데 실패했습니다: $e')),
          );
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시물을 불러오는데 실패했습니다: $e')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
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

  String _formatTime(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case '오묵완':
        return const Color(0xFFB3C7F7); // 하늘색
      case '말씀나눔':
        return const Color(0xFFD1B3F7); // 연보라
      case '기도제목':
        return const Color(0xFFB3F7E0); // 민트
      case '고민':
        return const Color(0xFFF7E6B3); // 연노랑
      case '교회추천':
        return const Color(0xFFF7B3B3); // 연빨강
      default:
        return const Color(0xFFF2F2F7);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body = const SizedBox.shrink();
    if (_bottomIndex == 0) {
      body = const OmukwanScreen();
    } else if (_bottomIndex == 1) {
      body = Column(
        children: [
          // 상단 앱바
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '나눔',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A3A4A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.search_rounded,
                                size: 28, color: Color(0xFF4B4B5B)),
                            splashRadius: 24,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SearchScreen()),
                              );
                            },
                          ),
                        ),
                        _buildNotificationIcon(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 카테고리 탭
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) =>
                          _buildCategoryTab(categories[idx], idx),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 게시글 리스트
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadPosts(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                itemCount: posts.length + 1,
                itemBuilder: (context, idx) {
                  if (idx == posts.length) {
                    return _buildLoadingIndicator();
                  }
                  return _buildPostCard(idx);
                },
              ),
            ),
          ),
        ],
      );
    } else if (_bottomIndex == 2) {
      body = const GroupListScreen();
    } else if (_bottomIndex == 3) {
      body = const ProfileScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: body),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: _bottomIndex == 1
          ? Container(
              height: 240,
              width: 72,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  if (_isWriteMenuOpen) ...[
                    Positioned(
                      bottom: 160,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        tween: Tween(
                            begin: 0.0, end: _isWriteMenuOpen ? 1.0 : 0.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: FloatingActionButton(
                          heroTag: 'omukwan',
                          onPressed: () {
                            setState(() => _isWriteMenuOpen = false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const WriteOmukwanScreen()),
                            ).then((result) {
                              if (mounted && result == true) {
                                _loadPosts(refresh: true);
                              }
                            });
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
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        tween: Tween(
                            begin: 0.0, end: _isWriteMenuOpen ? 1.0 : 0.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: FloatingActionButton(
                          heroTag: 'post',
                          onPressed: () {
                            setState(() => _isWriteMenuOpen = false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const WritePostScreen()),
                            ).then((result) {
                              if (mounted && result == true) {
                                _loadPosts(refresh: true);
                              }
                            });
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
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutBack,
                      tween:
                          Tween(begin: 0.0, end: _isWriteMenuOpen ? 1.0 : 0.0),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 0.25 * 3.14159,
                          child: Transform.scale(
                            scale: 1.0 + (value * 0.1),
                            child: child,
                          ),
                        );
                      },
                      child: FloatingActionButton(
                        heroTag: 'toggle',
                        onPressed: () {
                          setState(() => _isWriteMenuOpen = !_isWriteMenuOpen);
                        },
                        backgroundColor: const Color(0xFF7BA7F7),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            _isWriteMenuOpen ? Icons.close : Icons.edit,
                            key: ValueKey<String>(
                                _isWriteMenuOpen ? 'close' : 'edit'),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildCategoryTab(String category, int idx) {
    final isSelected = _categoryIndex == idx;
    return GestureDetector(
      onTap: () {
        setState(() => _categoryIndex = idx);
        _loadPosts(refresh: true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7BA7F7) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7BA7F7).withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryIcons[category] ?? Icons.category,
              size: 17,
              color: isSelected ? Colors.white : const Color(0xFF8E8E93),
            ),
            const SizedBox(width: 6),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(int idx) {
    final post = posts[idx];
    final scale = likeScales.length > idx ? likeScales[idx] : 1.0;
    final bool expanded = post['expanded'] as bool;
    final String content = post['content'] as String;
    final String? imageUrl = post['image_url'] as String?;
    final String? mode = post['mode'] as String?;
    final String? q1Answer = post['q1_answer'] as String?;
    final String? q2Answer = post['q2_answer'] as String?;
    final String? q3Answer = post['q3_answer'] as String?;
    final lines = content.split('\n');
    final preview = expanded ? content : lines.take(3).join('\n');
    final isLong = lines.length > 3;
    String? profileImageUrl = post['profile_image_url'];
    if (profileImageUrl != null &&
        profileImageUrl.isNotEmpty &&
        profileImageUrl.startsWith('/')) {
      profileImageUrl = ApiService.baseUrl + profileImageUrl;
    }

    // 하트 애니메이션 상태 관리
    final ValueNotifier<bool> likeAnim = ValueNotifier(false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: post['id']),
          ),
        ).then((_) {
          if (mounted) {
            _loadPosts(refresh: true);
          }
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 2,
        color: Colors.white,
        shadowColor: const Color(0x1A7BA7F7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFB3C7F7),
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : null,
                    child: profileImageUrl == null || profileImageUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['nickname'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF3A3A4A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post['time'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB0B3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _categoryColor(post['category']),
                      borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 20),
              if (mode == 'template' && post['category'] == '오묵완') ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (q1Answer != null) ...[
                      _buildOmukwanAnswer(
                          '1. 이 말씀을 통해 알게된 하나님은 누구십니까?', q1Answer),
                      const SizedBox(height: 12),
                    ],
                    if (q2Answer != null) ...[
                      _buildOmukwanAnswer(
                          '2. 성령님, 이 말씀을 통하여 저에게 무엇을 말씀하시길 원하십니까?', q2Answer),
                      const SizedBox(height: 12),
                    ],
                    if (q3Answer != null) ...[
                      _buildOmukwanAnswer(
                          '3. 성령님, 주신 말씀에 따라 제가 구체적으로 어떻게 하기를 원하십니까?',
                          q3Answer),
                    ],
                  ],
                ),
              ] else ...[
                Text(
                  preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF23233A),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                  ),
                ),
                if (isLong && !expanded)
                  GestureDetector(
                    onTap: () => setState(() => posts[idx]['expanded'] = true),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8),
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
              ],
              if (imageUrl != null) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    '${Env.baseUrl}$imageUrl',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 240,
                    errorBuilder: (context, error, stackTrace) {
                      print('Image loading error: $error');
                      return Container(
                        width: double.infinity,
                        height: 240,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Color(0xFF8E8E93),
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      try {
                        if (post['liked_by_me']) {
                          await _apiService.unlikePost(post['id']);
                          setState(() {
                            post['liked_by_me'] = false;
                            post['likes_count'] =
                                (post['likes_count'] as int) - 1;
                            likeScales[idx] = 1.3;
                          });
                        } else {
                          await _apiService.likePost(post['id']);
                          setState(() {
                            post['liked_by_me'] = true;
                            post['likes_count'] =
                                (post['likes_count'] as int) + 1;
                            likeScales[idx] = 1.3;
                          });
                        }
                        Future.delayed(const Duration(milliseconds: 150), () {
                          if (mounted) setState(() => likeScales[idx] = 1.0);
                        });
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다: $e')),
                          );
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: AnimatedScale(
                        scale: scale,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: Row(
                          children: [
                            Icon(
                              post['liked_by_me']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: post['liked_by_me']
                                  ? const Color(0xFF7BA7F7)
                                  : const Color(0xFFB0B3B8),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post['likes_count'] ?? 0}',
                              style: TextStyle(
                                fontSize: 14,
                                color: post['liked_by_me']
                                    ? const Color(0xFF7BA7F7)
                                    : const Color(0xFFB0B3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.mode_comment_outlined,
                          size: 18,
                          color: Color(0xFFB0B3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post['comments'],
                          style: const TextStyle(
                            color: Color(0xFFB0B3B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOmukwanAnswer(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7BA7F7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          answer,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF3A3A4A),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    if (!hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            '더 이상 불러올 게시물이 없습니다',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7BA7F7)),
              ),
              SizedBox(height: 8),
              Text(
                '이전 게시물을 불러오는 중...',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
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
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '오묵완'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border), label: '나눔'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: '그룹'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
          ],
          currentIndex: _bottomIndex,
          onTap: (idx) {
            setState(() {
              _bottomIndex = idx;
              if (idx == 1) {
                // 나눔 페이지로 이동할 때
                _loadPosts(refresh: true);
              }
            });
          },
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return badges.Badge(
      showBadge: _unreadNotificationCount > 0,
      badgeContent: Text(
        _unreadNotificationCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
      ),
      badgeStyle: badges.BadgeStyle(
        badgeColor: const Color(0xFFFF3B30),
        padding: const EdgeInsets.all(4),
        borderRadius: BorderRadius.circular(8),
        elevation: 0,
      ),
      position: badges.BadgePosition.topEnd(top: -2, end: -2),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: IconButton(
          icon: const Icon(
            Icons.notifications_rounded,
            size: 26,
            color: Color(0xFF1C1C1E),
          ),
          splashRadius: 24,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            ).then((_) {
              _loadUnreadNotificationCount();
            });
          },
        ),
      ),
    );
  }
}
