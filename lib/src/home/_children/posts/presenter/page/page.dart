import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';

class PostsPage extends StatelessWidget {
  final bool isFeed;
  const PostsPage({super.key, required this.isFeed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: PublicationsList(scrollKey: "allPosts", isFeed: isFeed, isOtherUser: false),
    );
  }
}
