import 'package:flutter/material.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import '../../services/api_service.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({Key? key}) : super(key: key);

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      setState(() => _isLoading = true);
      final response = await _apiService.getGroups();
      setState(() {
        _groups = List<Map<String, dynamic>>.from(response['groups']);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('그룹 목록을 불러오는데 실패했습니다: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _leaveGroup(String groupId) async {
    try {
      await _apiService.leaveGroup(groupId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('그룹을 탈퇴했습니다.')),
        );
        _loadGroups(); // 그룹 목록 새로고침
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('그룹 탈퇴에 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _showLeaveConfirmDialog(Map<String, dynamic> group) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('그룹 탈퇴'),
          content: Text('${group['title']} 그룹을 탈퇴하시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                '탈퇴',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _leaveGroup(group['id'].toString());
              },
            ),
          ],
        );
      },
    );
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '그룹',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3A3A4A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        size: 28, color: Color(0xFF4B4B5B)),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateGroupScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadGroups();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 그룹 리스트
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF7BA7F7)),
                      ),
                    )
                  : _groups.isEmpty
                      ? const Center(
                          child: Text(
                            '가입된 그룹이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadGroups,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _groups.length,
                            itemBuilder: (context, index) {
                              final group = _groups[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 2,
                                color: Colors.white,
                                shadowColor: const Color(0x1A7BA7F7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GroupDetailScreen(
                                          groupId: group['id'],
                                          groupTitle: group['title'],
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                group['title'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF3A3A4A),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF2F2F7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${group['memberCount']}명',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF4B4B5B),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                PopupMenuButton<String>(
                                                  icon: const Icon(
                                                    Icons.more_vert,
                                                    color: Color(0xFF8E8E93),
                                                    size: 20,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  elevation: 3,
                                                  position:
                                                      PopupMenuPosition.under,
                                                  itemBuilder:
                                                      (BuildContext context) =>
                                                          [
                                                    PopupMenuItem<String>(
                                                      value: 'leave',
                                                      height: 48,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: const Color(
                                                                    0xFFFFE5E5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: const Icon(
                                                                Icons
                                                                    .exit_to_app,
                                                                size: 18,
                                                                color: Color(
                                                                    0xFFFF3B30),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 12),
                                                            const Text(
                                                              '그룹 탈퇴',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xFF1C1C1E),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  onSelected: (String value) {
                                                    if (value == 'leave') {
                                                      _showLeaveConfirmDialog(
                                                          group);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.emoji_events_outlined,
                                              size: 16,
                                              color: Color(0xFF7BA7F7),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '오늘의 오묵완 ${group['todayOmukwanCount']}/${group['memberCount']}명',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF7BA7F7),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
