import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/core/globals/publications/publications.dart';
import 'package:mobile/core/storage/storage.dart';

class PostsPage extends StatefulWidget {
  final bool isFeed;
  const PostsPage({super.key, required this.isFeed});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<PublicationsListState> _publicationsKey =
      GlobalKey<PublicationsListState>();
  late final ScrollController _scrollController;
  late final scrollKey = "allPosts";
  Timer? _refreshTimer;
  bool _showRefreshButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final currentOffset = _scrollController.offset;
        ScrollStorage.setOffset(scrollKey, currentOffset);
      }
    });
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(minutes: 5), () {
      if (mounted) {
        setState(() {
          _showRefreshButton = true;
        });
      }
    });
  }

  Future<void> refreshPublications() async {
    setState(() {
      _showRefreshButton = false;
    });
    ScrollStorage.setOffset(scrollKey, 0.0);
    if (_publicationsKey.currentState != null) {
      await _publicationsKey.currentState!.refresh();
    }
    _startRefreshTimer();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: refreshPublications,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                PublicationsList(
                  key: _publicationsKey,
                  scrollKey: scrollKey,
                  isFeed: widget.isFeed,
                  isOtherUser: false,
                  scrollController: _scrollController,
                ),
              ],
            ),
          ),
          if (_showRefreshButton)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: FittedBox(
                  child: ElevatedButton.icon(
                    onPressed: refreshPublications,
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text(
                      "Recent posts",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
