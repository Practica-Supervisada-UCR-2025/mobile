import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/comments/presenter/widgets/comment_input_box.dart';

class CommentsPage extends StatelessWidget {
  final Publication publication;

  const CommentsPage({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: const Text("Comentarios"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _PostPreview(publication: publication),
                const Divider(height: 1),
                const CommentsList(),
              ],
            ),
          ),
          const CommentInputBox(),
        ],
      ),
    );
  }
}

class _PostPreview extends StatelessWidget {
  final Publication publication;

  const _PostPreview({required this.publication});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(publication.profileImageUrl),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  publication.username,
                  style: textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            publication.content,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          if (publication.attachment != null &&
              publication.attachment!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  publication.attachment!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CommentsList extends StatelessWidget {
  const CommentsList({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: colorScheme.outline),
        itemBuilder: (_, index) {
          return Container(
            color: colorScheme.surface, 
            child: ListTile(
              leading: const CircleAvatar(),
              title: Text(
                "Usuario123",
                style: textTheme.bodyMedium,
              ),
              subtitle: Text(
                "Este es un comentario de prueba",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


