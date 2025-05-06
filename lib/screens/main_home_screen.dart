import 'package:flutter/material.dart';
import 'write_post_screen.dart';
import 'write_omukwan_screen.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'profile_screen.dart';
import 'post_detail_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _categoryIndex = 0;
  int _bottomIndex = 0;
  bool _isWriteMenuOpen = false;
  final List<String> categories = ['전체', '오목완', '말씀나눔', '기도제목', '고민', '교회추천'];
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  DateTime? _lastApiCallTime;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  bool _isScrolling = false;
  Timer? _scrollEndTimer;

  List<Map<String, dynamic>> posts = [];
  bool isLoading = false;
  String? lastCursor;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeAndLoad();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollEndTimer?.cancel();
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
          };
        }).toList();

        if (!mounted) return;

        setState(() {
          posts.addAll(processedPosts);
          lastCursor = meta['nextCursor'];
          hasMore = meta['hasNextPage'] ?? false;
          isLoading = false;
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

  Future<void> _initializeServices() async {
    try {
      print('Initializing ApiService...');
      await _apiService.initialize();
      print('ApiService initialized successfully');
    } catch (e) {
      print('Failed to initialize ApiService: $e');
    }
  }

  Future<void> _initializeAndLoad() async {
    try {
      print('Starting initialization and loading...');
      await _initializeServices();
      await _loadPosts();
      print('Initialization and loading completed');
    } catch (e) {
      print('Error during initialization and loading: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('초기화 중 오류가 발생했습니다: $e')),
        );
      }
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
      case '오목완':
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
    Widget body;
    if (_bottomIndex == 0) {
      body = Column(
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
            child: RefreshIndicator(
              onRefresh: () => _loadPosts(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 24, bottom: 24),
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
      body = const ProfileScreen();
    } else {
      body = const Center(child: Text('소모임(추후 구현)'));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(child: body),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: _bottomIndex == 0
          ? Container(
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
                                  builder: (context) =>
                                      const WriteOmukwanScreen()),
                            ).then((_) {
                              if (mounted) {
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
                                  builder: (context) =>
                                      const WritePostScreen()),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7BA7F7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF7BA7F7) : const Color(0xFFE5E5EA),
          ),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF8E8E93),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(int idx) {
    final post = posts[idx];
    final bool expanded = post['expanded'] as bool;
    final String content = post['content'] as String;
    final String? imageUrl = post['image_url'] as String?;
    final lines = content.split('\n');
    final preview = expanded ? content : lines.take(3).join('\n');
    final isLong = lines.length > 3;
    String? profileImageUrl = post['profile_image_url'];
    if (profileImageUrl != null &&
        profileImageUrl.isNotEmpty &&
        profileImageUrl.startsWith('/')) {
      profileImageUrl = ApiService.baseUrl + profileImageUrl;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        ).then((_) {
          if (mounted) {
            _loadPosts(refresh: true);
          }
        });
      },
      child: Card(
        key: ValueKey('post_$idx'),
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
                  profileImageUrl != null && profileImageUrl.isNotEmpty
                      ? CircleAvatar(
                          backgroundColor: post['profileColor'],
                          backgroundImage: NetworkImage(profileImageUrl),
                          radius: 20,
                        )
                      : CircleAvatar(
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
                preview,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
              if (imageUrl != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'http://10.0.2.2:3000$imageUrl',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      print('Image loading error: $error');
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: const Color(0xFFF2F2F7),
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
              const SizedBox(height: 18),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        if (post['liked_by_me']) {
                          await _apiService.unlikePost(post['id']);
                          setState(() {
                            post['liked_by_me'] = false;
                            post['likes_count'] =
                                (post['likes_count'] as int) - 1;
                          });
                        } else {
                          await _apiService.likePost(post['id']);
                          setState(() {
                            post['liked_by_me'] = true;
                            post['likes_count'] =
                                (post['likes_count'] as int) + 1;
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다: $e')),
                          );
                        }
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          post['liked_by_me']
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: post['liked_by_me']
                              ? const Color(0xFF7BA7F7)
                              : const Color(0xFFB0B3B8),
                          size: 20,
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
                  const SizedBox(width: 18),
                  Icon(
                    Icons.mode_comment_outlined,
                    size: 20,
                    color: Color(0xFFB0B3B8),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    post['comments'],
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
      ),
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
      onTap: (idx) {
        setState(() => _bottomIndex = idx);
      },
      elevation: 8,
    );
  }
}
