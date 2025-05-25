import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupTitle;

  const GroupDetailScreen({
    Key? key,
    required this.groupId,
    required this.groupTitle,
  }) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _writtenMembers = [];
  List<Map<String, dynamic>> _notWrittenMembers = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _members = [];
  bool _isMembersLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      if (_tabController.index == 1) {
        _loadGroupMembers();
      }
    });
    _loadTodayOmukwanStatus();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ko'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadTodayOmukwanStatus();
    }
  }

  Future<void> _loadTodayOmukwanStatus() async {
    try {
      setState(() => _isLoading = true);
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final response =
          await _apiService.getTodayOmukwanStatus(widget.groupId, dateStr);
      setState(() {
        _writtenMembers =
            List<Map<String, dynamic>>.from(response['writtenMembers']);
        _notWrittenMembers =
            List<Map<String, dynamic>>.from(response['notWrittenMembers']);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오묵완 목록을 불러오는데 실패했습니다: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserTodayOmukwans(String userId) async {
    try {
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final response = await _apiService.getUserTodayOmukwans(
          widget.groupId, dateStr, userId);
      final posts = List<Map<String, dynamic>>.from(response['posts']);
      _showUserPosts(context, response['user'], posts);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자의 오묵완을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _loadGroupMembers() async {
    setState(() {
      _isMembersLoading = true;
    });
    try {
      final members = await _apiService.getGroupMembers(widget.groupId);
      setState(() {
        _members = members;
        _isMembersLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('멤버 목록을 불러오는데 실패했습니다: $e')),
        );
      }
      setState(() {
        _isMembersLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.groupTitle,
          style: const TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF007AFF)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF7BA7F7),
          unselectedLabelColor: const Color(0xFF8E8E93),
          indicatorColor: const Color(0xFF7BA7F7),
          tabs: const [
            Tab(
              icon: Icon(Icons.assignment_outlined),
              text: '오늘의 오묵완',
            ),
            Tab(
              icon: Icon(Icons.people_outline),
              text: '멤버 목록',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayOmukwanTab(),
          _buildMembersTab(),
        ],
      ),
    );
  }

  Widget _buildTodayOmukwanTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7BA7F7)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTodayOmukwanStatus,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._writtenMembers.map((member) => _buildUserCard(member)),
          ..._notWrittenMembers.map((member) => _buildNotWrittenCard(member)),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    if (_isMembersLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showAddMemberDialog(context);
                },
                icon: const Icon(Icons.person_add, size: 20),
                label: const Text('멤버 추가'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7BA7F7),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _members.isEmpty
              ? const Center(child: Text('멤버가 없습니다.'))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    ..._members.map((member) => _buildMemberCard({
                          'id': member['user']['id'],
                          'nickname': member['user']['nickname'],
                          'profileImageUrl': member['user']
                              ['profile_image_url'],
                          'isCreator': member['is_creator'] ?? false,
                        })),
                  ],
                ),
        ),
      ],
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    Map<String, dynamic>? searchResult;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFF2F2F7),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '멤버 초대',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3A3A4A),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF8E8E93)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            hintText: '전화번호를 입력하세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFF2F2F7),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFF2F2F7),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF7BA7F7),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (phoneController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('전화번호를 입력해주세요'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  final result =
                                      await _apiService.searchUserByPhone(
                                    phoneController.text,
                                  );
                                  setState(() {
                                    searchResult = result;
                                    isLoading = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('사용자를 찾을 수 없습니다: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7BA7F7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('검색'),
                      ),
                    ],
                  ),
                ),
                if (searchResult != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      color: Colors.white,
                      shadowColor: const Color(0x1A7BA7F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFB3C7F7),
                              backgroundImage:
                                  searchResult!['profile_image_url'] != null
                                      ? NetworkImage(
                                          searchResult!['profile_image_url'])
                                      : null,
                              child: searchResult!['profile_image_url'] == null
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                searchResult!['nickname'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF3A3A4A),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await _apiService.inviteUserToGroup(
                                    widget.groupId,
                                    phoneController.text,
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('초대가 완료되었습니다'),
                                      ),
                                    );
                                    _loadGroupMembers();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('초대에 실패했습니다: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7BA7F7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('추가'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 0,
                    itemBuilder: (context, index) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shadowColor: const Color(0x1A7BA7F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _loadUserTodayOmukwans(member['id']),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFB3C7F7),
                backgroundImage: member['profile_image_url'] != null
                    ? NetworkImage(member['profile_image_url'])
                    : null,
                child: member['profile_image_url'] == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  member['nickname'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF3A3A4A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7BA7F7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '작성완료',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7BA7F7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserPosts(BuildContext context, Map<String, dynamic> user,
      List<Map<String, dynamic>> posts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFF2F2F7),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFB3C7F7),
                      backgroundImage: user['profile_image_url'] != null
                          ? NetworkImage(user['profile_image_url'])
                          : null,
                      child: user['profile_image_url'] == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user['nickname'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF3A3A4A),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF8E8E93)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      color: Colors.white,
                      shadowColor: const Color(0x1A7BA7F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF3A3A4A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (post['mode'] == 'free') ...[
                              Text(
                                post['content'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF3A3A4A),
                                  height: 1.5,
                                ),
                              ),
                            ] else ...[
                              _buildTemplatePost(post),
                            ],
                            const SizedBox(height: 12),
                            Text(
                              _formatTime(post['created_at']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatePost(Map<String, dynamic> post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionAnswer('이 말씀을 통해 알게된 하나님은 누구십니까?', post['q1_answer']),
        const SizedBox(height: 16),
        _buildQuestionAnswer(
            '성령님, 이 말씀을 통하여 저에게 무엇을 말씀하시길 원하십니까?', post['q2_answer']),
        const SizedBox(height: 16),
        _buildQuestionAnswer(
            '성령님, 주신 말씀에 따라 제가 구체적으로 어떻게 하기를 원하십니까?', post['q3_answer']),
      ],
    );
  }

  Widget _buildQuestionAnswer(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7BA7F7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF3A3A4A),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildNotWrittenCard(Map<String, dynamic> member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: const Color(0xFFF2F2F7),
      shadowColor: const Color(0x1A7BA7F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFB3C7F7),
              backgroundImage: member['profile_image_url'] != null
                  ? NetworkImage(member['profile_image_url'])
                  : null,
              child: member['profile_image_url'] == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                member['nickname'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF3A3A4A),
                ),
              ),
            ),
            const Text(
              '아직 작성하지 않았어요',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shadowColor: const Color(0x1A7BA7F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFB3C7F7),
              backgroundImage: member['profileImageUrl'] != null
                  ? NetworkImage(member['profileImageUrl'])
                  : null,
              child: member['profileImageUrl'] == null
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
                        member['nickname'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF3A3A4A),
                        ),
                      ),
                      if (member['isCreator'] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7BA7F7).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '방장',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7BA7F7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (member['isCreator'] == true)
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF8E8E93),
                ),
                onPressed: () {
                  // TODO: 멤버 관리 메뉴 표시
                },
              ),
          ],
        ),
      ),
    );
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
}
