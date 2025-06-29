import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/comments/comments.dart';

class CommentsPage extends StatelessWidget {
  final Publication publication;

  const CommentsPage({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    final unifiedBackgroundColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: unifiedBackgroundColor,
      appBar: AppBar(
        backgroundColor: unifiedBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text("Comments"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              return CommentsLoadBloc(
                repository: CommentsRepositoryImpl(
                  apiService: Provider.of<ApiService>(context, listen: false),
                ),
                postId: publication.id.toString(),
              )..add(FetchInitialComments());
            },
          ),
          BlocProvider(
            create:
                (context) => CommentsCreateBloc(
                  commentsRepository: CommentsRepositoryImpl(
                    apiService: Provider.of<ApiService>(context, listen: false),
                  ),
                ),
          ),
        ],
        child: BlocListener<CommentsCreateBloc, CommentsCreateState>(
          listener: (context, state) {
            if (state is CommentSuccess) {
              context.read<CommentsLoadBloc>().add(FetchInitialComments());
              context.read<CommentsCreateBloc>().add(CommentReset());
            } else if (state is CommentFailure) {
              FeedbackSnackBar.showError(context, state.error);
            }
          },
          child: Column(
            children: [
              Expanded(child: CommentsList(publication: publication)),
              CommentInput(postId: publication.id),
            ],
          ),
        ),
      ),
    );
  }
}

class PostPreview extends StatelessWidget {
  final Publication publication;
  const PostPreview({super.key, required this.publication});

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
                child: Text(publication.username, style: textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            publication.content,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
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
