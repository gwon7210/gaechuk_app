import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../models/auth_models.dart';
import 'match_result_page.dart';

class MainPage extends StatefulWidget {
  final VoidCallback? onLogout;

  const MainPage({super.key, this.onLogout});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ChatRequestCounts? _chatCounts;
  TokenInfo? _tokenInfo;
  bool _isLoading = true;
  bool _isMatchingLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authService = context.read<AuthService>();
      final apiClient = authService.apiClient;

      final chatCountsFuture = apiClient.getChatRequestCounts();
      final tokenInfoFuture = apiClient.getTokenInfo();

      final results = await Future.wait([chatCountsFuture, tokenInfoFuture]);

      setState(() {
        _chatCounts = results[0] as ChatRequestCounts;
        _tokenInfo = results[1] as TokenInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showErrorSnackBar('데이터를 불러오는데 실패했습니다: $e');
      }
    }
  }

  Future<void> _handleMatch() async {
    if (_tokenInfo?.tokenCount == 0) {
      _showErrorSnackBar('만나가 부족합니다. 만나를 충전해주세요.');
      return;
    }

    setState(() {
      _isMatchingLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      final apiClient = authService.apiClient;

      final matchResponse = await apiClient.requestMatching();

      setState(() {
        _isMatchingLoading = false;
      });

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => MatchResultPage(
                  candidates: matchResponse.candidates,
                  onBack: () => _loadData(), // 데이터 새로고침
                ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isMatchingLoading = false;
      });

      if (mounted) {
        if (e is MatchException) {
          switch (e.errorType) {
            case MatchErrorType.insufficientTokens:
              _showErrorSnackBar('만나가 부족합니다. 만나를 충전해주세요.');
              break;
            case MatchErrorType.genderNotSet:
              _showErrorSnackBar('성별 정보를 먼저 설정해주세요.');
              break;
            case MatchErrorType.accountInactive:
              _showErrorSnackBar('계정이 비활성화되었습니다. 고객센터에 문의해주세요.');
              break;
            case MatchErrorType.noCandidates:
              _showErrorSnackBar('현재 매칭 가능한 상대가 없습니다. 잠시 후 다시 시도해주세요.');
              break;
            default:
              _showErrorSnackBar(e.message);
          }
        } else {
          _showErrorSnackBar('매칭 요청에 실패했습니다: $e');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('개척교회 청년들'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // 알림 기능
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout' && widget.onLogout != null) {
                widget.onLogout!();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 20),
                        SizedBox(width: 8),
                        Text('프로필'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('설정'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Color(0xFFEF4444)),
                        SizedBox(width: 8),
                        Text(
                          '로그아웃',
                          style: TextStyle(color: Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ),
                ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 메시지 카운트 섹션
                      _buildMessageCountSection(),
                      const SizedBox(height: 32),

                      // 만나 정보 섹션
                      _buildTokenSection(),
                      const SizedBox(height: 32),

                      // 매치 버튼
                      _buildMatchButton(),
                      const SizedBox(height: 32),

                      // 안내 메시지
                      _buildInfoMessage(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildMessageCountSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '메시지 현황',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildMessageCard(
                  title: '나에게 온 메시지',
                  count: _chatCounts?.incomingCount ?? 0,
                  subtitle: '상대방이 신청한 목록',
                  onTap: () {
                    // TODO: 받은 메시지 목록으로 이동
                    _showComingSoon('받은 메시지 목록');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMessageCard(
                  title: '내가 보낸 메시지',
                  count: _chatCounts?.outgoingCount ?? 0,
                  subtitle: '내가 신청한 목록',
                  onTap: () {
                    // TODO: 보낸 메시지 목록으로 이동
                    _showComingSoon('보낸 메시지 목록');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard({
    required String title,
    required int count,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monetization_on_outlined,
                  color: Color(0xFFF59E0B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '보유 만나',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '매칭에 필요한 만나 개수',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_tokenInfo?.tokenCount ?? 0}개',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFF59E0B),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '매칭 한 번당 만나 1개가 소모됩니다',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFA16207),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchButton() {
    final hasTokens = (_tokenInfo?.tokenCount ?? 0) > 0;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: hasTokens && !_isMatchingLoading ? _handleMatch : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasTokens ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
          foregroundColor: hasTokens ? Colors.white : const Color(0xFF94A3B8),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child:
            _isMatchingLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasTokens ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasTokens ? '매칭 시작하기' : '만나 부족',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF0284C7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '프로필을 완성하여 더 좋은 매칭을 받아보세요!',
              style: const TextStyle(fontSize: 14, color: Color(0xFF0369A1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('준비 중'),
            content: Text('$feature 기능은 곧 출시됩니다!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }
}
