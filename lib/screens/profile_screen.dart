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
      final posts = (response['posts'] as List)
          .map((post) => post as Map<String, dynamic>)
          .toList();

      setState(() {
        _omokwanPosts.clear();
        for (var post in posts) {
          final createdAt = DateTime.parse(post['created_at']);
          final localDate = DateTime(
            createdAt.year,
            createdAt.month,
            createdAt.day,
          );

          if (!_omokwanPosts.containsKey(localDate)) {
            _omokwanPosts[localDate] = [];
          }
          _omokwanPosts[localDate]!.add(post);
        }
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7BA7F7)),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  '사용자 정보를 불러오지 못했습니다.',
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 16,
                  ),
                ),
              );
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
                  // 헤더 부분
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '프로필',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Color(0xFF1C1C1E),
                            size: 28,
                          ),
                          onPressed: _navigateToSettings,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 프로필 정보
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? CircleAvatar(
                                  radius: 48,
                                  backgroundColor: const Color(0xFFB3C7F7),
                                  backgroundImage: NetworkImage(imageUrl),
                                )
                              : const CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Color(0xFFB3C7F7),
                                  child: Icon(Icons.person,
                                      size: 48, color: Colors.white),
                                ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          user['nickname'] ?? '-',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user['email'] ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8E8E93),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 캘린더
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7BA7F7).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
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
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
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
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Text(
                                          DateFormat('yyyy년 MM월 dd일', 'ko_KR')
                                              .format(selectedDay),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1C1C1E),
                                            letterSpacing: -0.5,
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
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF7BA7F7)
                                                            .withOpacity(0.1),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 10),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(24),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (omokwan['title'] !=
                                                          null) ...[
                                                        Text(
                                                          omokwan['title'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                                0xFF1C1C1E),
                                                            letterSpacing: -0.5,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 12),
                                                      ],
                                                      Text(
                                                        omokwan['content'] ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                          color:
                                                              Color(0xFF23233A),
                                                          height: 1.6,
                                                          letterSpacing: -0.3,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      Text(
                                                        DateFormat('HH:mm',
                                                                'ko_KR')
                                                            .format(
                                                          DateTime.parse(omokwan[
                                                              'created_at']),
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF8E8E93),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.5,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Color(0xFF7BA7F7),
                            size: 28,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Color(0xFF7BA7F7),
                            size: 28,
                          ),
                        ),
                        calendarStyle: const CalendarStyle(
                          outsideDaysVisible: false,
                          weekendTextStyle: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 16,
                          ),
                          defaultTextStyle: TextStyle(
                            color: Color(0xFF1C1C1E),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          todayTextStyle: TextStyle(
                            color: Color(0xFF1C1C1E),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          weekendStyle: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            final dateKey =
                                DateTime(date.year, date.month, date.day);
                            final posts = _omokwanPosts[dateKey];
                            if (posts != null && posts.isNotEmpty) {
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
                  ),
                  if (_selectedDay != null &&
                      _selectedDayOmokwan.isNotEmpty) ...[
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
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._selectedDayOmokwan.map((omokwan) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7BA7F7)
                                        .withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (omokwan['title'] != null) ...[
                                        Text(
                                          omokwan['title'],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1C1C1E),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      Text(
                                        omokwan['content'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          color: Color(0xFF23233A),
                                          height: 1.6,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
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
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF7BA7F7)),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
