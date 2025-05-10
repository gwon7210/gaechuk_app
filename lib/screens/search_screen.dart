import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'post_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> posts = [];
  bool isLoading = false;
  String? lastCursor;
  bool hasMore = true;
  String? currentKeyword;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoading && hasMore && currentKeyword != null) {
        _loadSearchResults();
      }
    }
  }

  Future<void> _loadSearchResults({bool refresh = false}) async {
    if (isLoading || (!refresh && !hasMore) || currentKeyword == null) return;

    setState(() {
      isLoading = true;
      if (refresh) {
        lastCursor = null;
        posts = [];
        hasMore = true;
      }
    });

    try {
      final response = await _apiService.searchPosts(
        keyword: currentKeyword!,
        cursor: lastCursor,
        limit: 10,
      );

      if (!mounted) return;

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

      setState(() {
        posts.addAll(processedPosts);
        lastCursor = meta['nextCursor'];
        hasMore = meta['hasNextPage'] ?? false;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 결과를 불러오는데 실패했습니다: $e')),
        );
        setState(() {
          isLoading = false;
        });
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

  Widget _buildPostCard(Map<String, dynamic> post) {
    final profileImageUrl = post['profile_image_url'];
    final imageUrl = post['image_url'];
    final isExpanded = post['expanded'] ?? false;
    final content = post['content'];
    final isLong = content.length > 100;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      elevation: 2,
      color: Colors.white,
      shadowColor: const Color(0x1A7BA7F7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(postId: post['id']),
            ),
          );
        },
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
                      Text(
                        post['time'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                isExpanded
                    ? content
                    : (isLong ? content.substring(0, 100) + '...' : content),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF3A3A4A),
                  height: 1.5,
                ),
              ),
              if (isLong && !isExpanded)
                GestureDetector(
                  onTap: () => setState(() => post['expanded'] = true),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '검색어를 입력하세요',
            hintStyle: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 16,
            ),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  setState(() {
                    currentKeyword = _searchController.text;
                  });
                  _loadSearchResults(refresh: true);
                }
              },
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                currentKeyword = value;
              });
              _loadSearchResults(refresh: true);
            }
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (currentKeyword != null && posts.isEmpty && !isLoading)
            const Expanded(
              child: Center(
                child: Text(
                  '검색 결과가 없습니다',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadSearchResults(refresh: true),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  itemCount: posts.length + 1,
                  itemBuilder: (context, idx) {
                    if (idx == posts.length) {
                      return _buildLoadingIndicator();
                    }
                    return _buildPostCard(posts[idx]);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
