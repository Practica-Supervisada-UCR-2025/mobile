import 'package:flutter/material.dart';
import './widgets.dart';

class PublicationsList extends StatefulWidget {
  const PublicationsList({super.key});

  @override
  State<PublicationsList> createState() => _PublicationsListState();
}

class _PublicationsListState extends State<PublicationsList> {
  final ScrollController _scrollController = ScrollController();
  final int _itemsPerPage = 5;
  bool _isLoading = false;
  bool _hasError = false;
  int _currentPage = 0;
  List<Map<String, dynamic>> _posts = [];

  // Simulated static data from backend (only 8 posts)
  final List<Map<String, dynamic>> _allPosts = List.generate(14, (index) {
    return {
      'id': index,
      'username': 'User',
      'profileImage': null,
      'createdAt': DateTime.now().subtract(Duration(days: index)),
      'text': 'This is a static post #$index.',
      'attachments': [],
      'reactions': 0,
      'comments': 0,
    };
  });

  @override
  void initState() {
    super.initState();
    _loadMore();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          !_hasError &&
          _posts.length < _allPosts.length) {
        _loadMore();
      }
    });
  }

  void _loadMore() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      try {
        final start = _currentPage * _itemsPerPage;
        final end = start + _itemsPerPage;
        final newItems = _allPosts.sublist(
          start,
          end > _allPosts.length ? _allPosts.length : end,
        );

        if (!mounted) return;
        setState(() {
          _posts.addAll(newItems);
          _currentPage++;
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_posts.isEmpty && !_isLoading && !_hasError) {
      return const Center(child: Text("You haven't posted anything yet."));
    }

    final bool isEndReached = _posts.length == _allPosts.length && !_isLoading;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _posts.length + (isEndReached ? 1 : 0),
            itemBuilder: (_, index) {
              if (index < _posts.length) {
                return PublicationCard(post: _posts[index]);
              } else {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: Text("There's nothing else to see."),
                  ),
                );
              }
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        if (_hasError)
          TextButton(
            onPressed: _loadMore,
            child: const Text('Retry loading posts'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
