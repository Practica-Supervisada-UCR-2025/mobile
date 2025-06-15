import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';

class ShowOwnPublicationsPage extends StatelessWidget {
  final bool refresh;
  final bool isFeed;
  const ShowOwnPublicationsPage({super.key, this.refresh = false, required this.isFeed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: PublicationsList(scrollKey: "ownPosts", isFeed: isFeed),
    );
  }
}
