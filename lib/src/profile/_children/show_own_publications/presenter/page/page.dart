import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';

class ShowOwnPublicationsPage extends StatelessWidget {
  const ShowOwnPublicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const PublicationsList(scrollKey: "ownPosts"),
    );
  }
}
