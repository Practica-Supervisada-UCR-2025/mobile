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
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (publication.userId != null) {
                        context.go(Paths.externProfile(publication.userId!));
                      }
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(DEFAULT_PROFILE_PIC),
                      foregroundImage: NetworkImage(publication.profileImageUrl),
                      radius: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (publication.userId != null) {
                          context.go(Paths.externProfile(publication.userId!));
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            publication.username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            relativeDate(publication.createdAt),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (publication.content.trim().isNotEmpty)
                Text(
                  publication.content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _InteractionButton(
                        icon: Icons.favorite_border,
                        label: publication.likes > 0 ? publication.likes.toString() : '',
                        onPressed: () {
                          // Like functionality
                        },
                      ),
                      const SizedBox(width: 24),
                      _InteractionButton(
                        icon: Icons.chat_bubble_outline,
                        label: publication.comments.toString(),
                        onPressed: () {
                          // Comment functionality
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 0.3,
          height: 0,
        ),
      ],
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 14)),
            ]
          ],
        ),
      ),
    );
  }
}
