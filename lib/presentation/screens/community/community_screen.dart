import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  // ... (existing code)
}

class _CommunityScreenState extends State<CommunityScreen> {
  late ScrollController _scrollController;
  late bool isLoading;
  late bool hasMore;
  late List<Post> _posts;
  late int currentPage;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadPosts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadPosts();
    }
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (isLoading || (!refresh && !hasMore)) return;

    setState(() {
      isLoading = true;
    });

    try {
      final posts = await _postRepository.getPosts(
        page: refresh ? 1 : currentPage,
        limit: 10,
      );

      setState(() {
        if (refresh) {
          _posts = posts;
          currentPage = 1;
        } else {
          _posts.addAll(posts);
          currentPage++;
        }
        hasMore = posts.length == 10;
      });
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ... (rest of the existing code)
}
