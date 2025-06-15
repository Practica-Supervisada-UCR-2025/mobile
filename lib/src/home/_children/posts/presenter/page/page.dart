import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    Container(
      color: Theme.of(context).colorScheme.surface,
      child: const PublicationsList(scrollKey: "allPosts"),
    );
  }
}
