import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'post_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final loadedNotifications = await _apiService.getNotifications();
      setState(() {
        notifications = loadedNotifications;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알림을 불러오는데 실패했습니다: $e')),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    try {
      // 알림 읽음 처리
      await _apiService.markNotificationAsRead(notification['id']);

      // 모든 알림 타입에서 게시물로 이동
      if (notification['related_id'] != null) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PostDetailScreen(postId: notification['related_id']),
            ),
          ).then((_) {
            _loadNotifications();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알림 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      final url = '${ApiService.baseUrl}/notifications/$notificationId';
      final response =
          await _apiService.delete('/notifications/$notificationId');
      if (mounted) {
        setState(() {
          notifications.removeWhere((n) => n['id'] == notificationId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알림이 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알림 삭제에 실패했습니다: $e')),
        );
      }
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'reply':
        return Icons.reply;
      default:
        return Icons.notifications;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    '알림',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A3A4A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 알림 리스트
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notifications.isEmpty
                      ? const Center(
                          child: Text(
                            '알림이 없습니다',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 16,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadNotifications,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return GestureDetector(
                                onTap: () =>
                                    _handleNotificationTap(notification),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: notification['is_read']
                                        ? const Color(0xFFF8F9FB)
                                        : const Color(0xFFF0F4FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7BA7F7),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          _getNotificationIcon(
                                              notification['type']),
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification['message'],
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                    notification['is_read']
                                                        ? FontWeight.w500
                                                        : FontWeight.w600,
                                                color: const Color(0xFF3A3A4A),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _formatTime(
                                                  notification['created_at']),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFFB0B3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 케밥 메뉴 버튼
                                      IconButton(
                                        icon: const Icon(Icons.more_vert,
                                            size: 20, color: Color(0xFFB0B3B8)),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return SafeArea(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      title: const Text('삭제',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        _deleteNotification(
                                                            notification['id']);
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.close),
                                                      title: const Text('닫기'),
                                                      onTap: () =>
                                                          Navigator.pop(
                                                              context),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
