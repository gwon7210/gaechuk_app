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

      // 그룹 초대 알림인 경우 게시글로 이동하지 않음
      if (notification['type'] == 'group_invite') {
        return;
      }

      // 다른 알림 타입에서는 게시물로 이동
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

  Future<void> _handleGroupInviteResponse(
      String notificationId, bool isAccept) async {
    try {
      if (isAccept) {
        await _apiService
            .post('/groups/invites/$notificationId/accept', body: {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('그룹 초대를 수락했습니다')),
          );
        }
      } else {
        await _apiService
            .post('/groups/invites/$notificationId/decline', body: {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('그룹 초대를 거절했습니다')),
          );
        }
      }
      // 알림 목록 새로고침
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('처리 중 오류가 발생했습니다: $e')),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '알림',
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7BA7F7)),
              ),
            )
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    '알림이 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFF2F2F7),
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _handleNotificationTap(notification),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getNotificationIcon(notification['type']),
                                    color: const Color(0xFF7BA7F7),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      notification['message'] ?? '',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: const Color(0xFF3A3A4A),
                                        fontWeight: notification['is_read']
                                            ? FontWeight.w400
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatTime(notification['created_at']),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Color(0xFF8E8E93),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return SafeArea(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                  ),
                                                  title: const Text(
                                                    '삭제',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    _deleteNotification(
                                                        notification['id']);
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.close,
                                                    color: Color(0xFF8E8E93),
                                                  ),
                                                  title: const Text(
                                                    '닫기',
                                                    style: TextStyle(
                                                      color: Color(0xFF8E8E93),
                                                    ),
                                                  ),
                                                  onTap: () =>
                                                      Navigator.pop(context),
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
                              if (notification['type'] == 'group_invite' &&
                                  !notification['is_read']) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () =>
                                          _handleGroupInviteResponse(
                                        notification['related_id'],
                                        false,
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFF8E8E93),
                                        side: const BorderSide(
                                          color: Color(0xFF8E8E93),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('거절'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _handleGroupInviteResponse(
                                        notification['related_id'],
                                        true,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF7BA7F7),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('수락'),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
