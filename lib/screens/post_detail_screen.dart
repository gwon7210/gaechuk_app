import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailScreen({
    Key? key,
    required this.post,
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

  @override
  void initState() {
    super.initState();
    _loadComments();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final comments = await _apiService.getComments(widget.post['id']);
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
        postId: widget.post['id'],
        content: _commentController.text.trim(),
        parentId: _replyingTo,
      );
      _commentController.clear();
      setState(() {
        _replyingTo = null;
        _replyingToContent = null;
      });
      await _loadComments();

      // 댓글 수 업데이트
      setState(() {
        widget.post['comments'] =
            (int.tryParse(widget.post['comments']) ?? 0 + 1).toString();
      });
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
              profileImageUrl != null && profileImageUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(profileImageUrl),
                    )
                  : const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFB3C7F7),
                      child: Icon(Icons.person, color: Colors.white, size: 20),
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
                              backgroundImage:
                                  widget.post['profile_image_url'] != null
                                      ? NetworkImage(
                                          widget.post['profile_image_url'])
                                      : null,
                              child: widget.post['profile_image_url'] == null
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post['nickname'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.5,
                                    color: Color(0xFF3A3A4A),
                                  ),
                                ),
                                Text(
                                  widget.post['time'],
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
                        Text(
                          widget.post['content'],
                          style: const TextStyle(
                            fontSize: 15.5,
                            color: Color(0xFF23233A),
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                              color: Color(0xFF8E8E93),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.post['comments']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 댓글 목록
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_comments.isEmpty)
                  const Center(
                    child: Text(
                      '아직 댓글이 없습니다.',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 14,
                      ),
                    ),
                  )
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
}
