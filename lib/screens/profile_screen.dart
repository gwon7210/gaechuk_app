import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'settings_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userFuture;
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Map<String, dynamic>>> _omokwanPosts = {};
  bool _isLoadingOmokwan = false;
  List<Map<String, dynamic>> _selectedDayOmokwan = [];

  @override
  void initState() {
    super.initState();
    _userFuture = _apiService.getMe();
    _loadOmokwanCounts(_focusedDay.year, _focusedDay.month);
  }

  Future<void> _loadOmokwanCounts(int year, int month) async {
    try {
      final response = await _apiService.getMyOmokwanCountByMonth(year, month);
      print('API Response: $response');

      final posts = (response['posts'] as List)
          .map((post) => post as Map<String, dynamic>)
          .toList();
      print('Parsed posts: $posts');

      setState(() {
        _omokwanPosts.clear();
        for (var post in posts) {
          final createdAt = DateTime.parse(post['created_at']);
          final localDate = DateTime(
            createdAt.year,
            createdAt.month,
            createdAt.day,
          );
          print(
              'Processing post: ${post['content']} at ${localDate.toIso8601String()}');

          if (!_omokwanPosts.containsKey(localDate)) {
            _omokwanPosts[localDate] = [];
          }
          _omokwanPosts[localDate]!.add(post);
        }
        print(
            'Final _omokwanPosts: ${_omokwanPosts.keys.map((d) => d.toIso8601String()).join(', ')}');
      });
    } catch (e) {
      print('Failed to load omokwan counts: $e');
    }
  }

  Future<void> _loadOmokwanByDate(DateTime date) async {
    setState(() => _isLoadingOmokwan = true);
    try {
      final omokwan = await _apiService.getMyOmokwanByDate(date);
      setState(() {
        _selectedDayOmokwan = omokwan;
        _isLoadingOmokwan = false;
      });
    } catch (e) {
      setState(() => _isLoadingOmokwan = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오목완을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _navigateToSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );

    if (mounted) {
      setState(() {
        _userFuture = _apiService.getMe();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '프로필',
          style: TextStyle(
            color: Color(0xFF3A3A4A),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('사용자 정보를 불러오지 못했습니다.'));
          }
          final user = snapshot.data!;
          String? imageUrl = user['profile_image_url'];
          if (imageUrl != null &&
              imageUrl.isNotEmpty &&
              imageUrl.startsWith('/')) {
            imageUrl = ApiService.baseUrl + imageUrl;
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      imageUrl != null && imageUrl.isNotEmpty
                          ? CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFFB3C7F7),
                              backgroundImage: NetworkImage(imageUrl),
                            )
                          : const CircleAvatar(
                              radius: 40,
                              backgroundColor: Color(0xFFB3C7F7),
                              child: Icon(Icons.person,
                                  size: 48, color: Colors.white),
                            ),
                      const SizedBox(height: 24),
                      Text(
                        user['nickname'] ?? '-',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user['email'] ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2025, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      final dateKey = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                      );
                      print('Selected date: ${dateKey.toIso8601String()}');
                      print(
                          'Available posts for selected date: ${_omokwanPosts[dateKey]}');

                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _selectedDayOmokwan = _omokwanPosts[dateKey] ?? [];
                      });

                      if (_selectedDayOmokwan.isNotEmpty) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: SafeArea(
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E5EA),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      DateFormat('yyyy년 MM월 dd일', 'ko_KR')
                                          .format(selectedDay),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1C1C1E),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      itemCount: _selectedDayOmokwan.length,
                                      itemBuilder: (context, index) {
                                        final omokwan =
                                            _selectedDayOmokwan[index];
                                        return Card(
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (omokwan['title'] !=
                                                    null) ...[
                                                  Text(
                                                    omokwan['title'],
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF1C1C1E),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                ],
                                                Text(
                                                  omokwan['content'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF1C1C1E),
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  DateFormat('HH:mm', 'ko_KR')
                                                      .format(
                                                    DateTime.parse(
                                                        omokwan['created_at']),
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 13,
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
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                      _loadOmokwanCounts(focusedDay.year, focusedDay.month);
                    },
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    locale: 'ko_KR',
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Color(0xFF7BA7F7),
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Color(0xFF7BA7F7),
                      ),
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Color(0xFF8E8E93)),
                      defaultTextStyle: TextStyle(
                        color: Color(0xFF1C1C1E),
                        fontSize: 15,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFF7BA7F7),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Color(0xFFF2F2F7),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      todayTextStyle: TextStyle(
                        color: Color(0xFF1C1C1E),
                        fontSize: 15,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                      ),
                      weekendStyle: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final dateKey =
                            DateTime(date.year, date.month, date.day);
                        final posts = _omokwanPosts[dateKey];
                        if (posts != null && posts.isNotEmpty) {
                          print(
                              'Showing marker for date: ${dateKey.toIso8601String()}');
                          return Positioned(
                            bottom: 1,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color(0xFF7BA7F7),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                if (_selectedDay != null && _selectedDayOmokwan.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('yyyy년 MM월 dd일', 'ko_KR')
                              .format(_selectedDay!),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._selectedDayOmokwan.map((omokwan) {
                          print(
                              'Rendering omokwan: ${omokwan['content']}'); // 디버깅용 로그
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (omokwan['title'] != null) ...[
                                    Text(
                                      omokwan['title'],
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1C1C1E),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Text(
                                    omokwan['content'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF1C1C1E),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
                if (_isLoadingOmokwan)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
