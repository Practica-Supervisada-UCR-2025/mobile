import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/comments/comments.dart';

class CommentsPage extends StatelessWidget {
  final Publication publication;

  const CommentsPage({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    final unifiedBackgroundColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: unifiedBackgroundColor,
      appBar: AppBar(
        backgroundColor: unifiedBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text("Comentarios"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocProvider(
        create: (context) => CommentsLoadBloc(
          repository: CommentsRepository(),
          postId: publication.id.toString(),
        )..add(FetchInitialComments()),
        child: Column(
          children: [
            Expanded(
              child: CommentsList(publication: publication),
            ),
            BlocProvider(
              create: (context) => CommentsCreateBloc(),
              child: CommentInputBox(textController: textController),
            ),
          ],
        ),
      ),
    );
  }
}

class PostPreview extends StatelessWidget {
  final Publication publication;
  const PostPreview({required this.publication});
  
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