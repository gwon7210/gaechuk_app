import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/env.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> _comments = [];
  bool _isLoading = false;
  String? _replyingTo;
  String? _replyingToContent;
  String? _currentUserId;
  Map<String, dynamic>? _post;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadComments();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    setState(() => _isLoading = true);
    try {
      final post = await _apiService.getPost(widget.postId);
      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글을 불러오는데 실패했습니다: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final comments = await _apiService.getComments(widget.postId);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글을 불러오는데 실패했습니다: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _apiService.getMe();
      setState(() {
        _currentUserId = user['id'];
      });
    } catch (e) {
      print('Failed to load current user: $e');
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await _apiService.createComment(
        postId: widget.postId,
        content: _commentController.text.trim(),
        parentId: _replyingTo,
      );
      _commentController.clear();
      setState(() {
        _replyingTo = null;
        _replyingToContent = null;
      });
      await _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 작성에 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _apiService.deleteComment(commentId);
      _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 삭제에 실패했습니다: $e')),
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

  Widget _buildCommentItem(Map<String, dynamic> comment,
      {int depth = 0, String? mentionNickname}) {
    final user = comment['user'];
    String? profileImageUrl = user['profile_image_url'];
    if (profileImageUrl != null &&
        profileImageUrl.isNotEmpty &&
        profileImageUrl.startsWith('/')) {
      profileImageUrl = ApiService.baseUrl + profileImageUrl;
    }
    double leftPadding = 0.0;
    if (depth == 1) leftPadding = 48.0;
    if (depth >= 2) leftPadding = 48.0;
    return Padding(
      padding: EdgeInsets.only(
        left: leftPadding,
        bottom: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFB3C7F7),
                backgroundImage: user['profile_image_url'] != null &&
                        user['profile_image_url'].isNotEmpty
                    ? NetworkImage(user['profile_image_url'].startsWith('/')
                        ? ApiService.baseUrl + user['profile_image_url']
                        : user['profile_image_url'])
                    : null,
                child: user['profile_image_url'] == null ||
                        user['profile_image_url'].isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user['nickname'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF3A3A4A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(comment['createdAt']),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB0B3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (mentionNickname != null)
                      Text('@$mentionNickname',
                          style: const TextStyle(
                              color: Color(0xFF7BA7F7), fontSize: 13)),
                    Text(
                      comment['content'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF23233A),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _replyingTo = comment['id'];
                              _replyingToContent = comment['content'];
                            });
                          },
                          child: const Text(
                            '답글',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7BA7F7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (user['id'] == _currentUserId) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _deleteComment(comment['id']),
                            child: const Text(
                              '삭제',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFF3B30),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _renderReplies(Map<String, dynamic> parentComment, int depth) {
    final replies =
        _comments.where((c) => c['parentId'] == parentComment['id']).toList();
    if (replies.isEmpty) return [];
    return replies.map((reply) {
      String? mentionNickname;
      if (depth >= 1 &&
          reply['parent'] != null &&
          reply['parent']['user'] != null) {
        mentionNickname = reply['parent']['user']['nickname'];
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentItem(reply,
              depth: depth, mentionNickname: mentionNickname),
          ..._renderReplies(reply, depth + 1),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _post == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '게시글',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF007AFF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // 게시글 내용
                Card(
                  elevation: 2,
                  color: Colors.white,
                  shadowColor: const Color(0x1A7BA7F7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFB3C7F7),
                              backgroundImage: _post?['user']
                                              ?['profile_image_url'] !=
                                          null &&
                                      _post!['user']['profile_image_url']
                                          .isNotEmpty
                                  ? NetworkImage(_post!['user']
                                              ['profile_image_url']
                                          .startsWith('/')
                                      ? ApiService.baseUrl +
                                          _post!['user']['profile_image_url']
                                      : _post!['user']['profile_image_url'])
                                  : null,
                              child: _post?['user']?['profile_image_url'] ==
                                          null ||
                                      _post!['user']['profile_image_url']
                                          .isEmpty
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _post?['user']?['nickname'] ?? '알 수 없음',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.5,
                                    color: Color(0xFF3A3A4A),
                                  ),
                                ),
                                Text(
                                  _formatTime(_post?['created_at'] ??
                                      DateTime.now().toIso8601String()),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB0B3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_post?['title'] != null) ...[
                          Text(
                            _post!['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (_post?['mode'] == 'template' &&
                            _post?['post_type'] == '오묵완') ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_post?['q1_answer'] != null) ...[
                                _buildOmukwanAnswer(
                                    '1. 이 말씀을 통해 알게된 하나님은 누구십니까?',
                                    _post!['q1_answer']),
                                const SizedBox(height: 16),
                              ],
                              if (_post?['q2_answer'] != null) ...[
                                _buildOmukwanAnswer(
                                    '2. 성령님, 이 말씀을 통하여 저에게 무엇을 말씀하시길 원하십니까?',
                                    _post!['q2_answer']),
                                const SizedBox(height: 16),
                              ],
                              if (_post?['q3_answer'] != null) ...[
                                _buildOmukwanAnswer(
                                    '3. 성령님, 주신 말씀에 따라 제가 구체적으로 어떻게 하기를 원하십니까?',
                                    _post!['q3_answer']),
                              ],
                            ],
                          ),
                        ] else ...[
                          Text(
                            _post?['content'] ?? '',
                            style: const TextStyle(
                              fontSize: 15.5,
                              color: Color(0xFF23233A),
                              height: 1.7,
                            ),
                          ),
                        ],
                        if (_post?['image_url'] != null) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              '${Env.baseUrl}${_post!['image_url']}',
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 댓글 목록
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  ..._comments
                      .where((c) => c['parentId'] == null)
                      .map((comment) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCommentItem(comment, depth: 0),
                        ..._renderReplies(comment, 1),
                      ],
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
          // 댓글 입력 영역
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_replyingTo != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_replyingToContent}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8E8E93),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _replyingTo = null;
                              _replyingToContent = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText:
                              _replyingTo != null ? '답글을 입력하세요' : '댓글을 입력하세요',
                          hintStyle: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF2F2F7),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _submitComment,
                      icon: const Icon(
                        Icons.send,
                        color: Color(0xFF7BA7F7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7BA7F7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 15.5,
            color: Color(0xFF3A3A4A),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
