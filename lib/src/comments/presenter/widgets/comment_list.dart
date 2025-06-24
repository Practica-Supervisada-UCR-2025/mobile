import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/globals/publications/domain/models/publication.dart';
import 'package:mobile/core/globals/widgets/feedback_snack_bar.dart';
import 'package:mobile/core/globals/publications/presenter/widgets/image_page.dart';
import 'package:mobile/core/router/paths.dart';
import 'package:mobile/src/comments/comments.dart';

class CommentsList extends StatefulWidget {
  final Publication publication;
  const CommentsList({super.key, required this.publication});

  @override
  State<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList> {
  late final ScrollController _scrollController;
  String? _lastErrorShown;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<CommentsLoadBloc>().add(FetchMoreComments());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Widget _buildAttachment(String url) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImagePreviewScreen(imageUrl: url),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          url,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Icon(Icons.error, color: Colors.grey),
            );
          },
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CommentsLoadBloc, CommentsLoadState>(
      builder: (context, state) {
        if (state is CommentsLoadInitial ||
            (state is CommentsLoading && state.isInitialFetch)) {
          return Column(
            children: [
              PostPreview(publication: widget.publication),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        }

        if (state is CommentsError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_lastErrorShown != state.message) {
              FeedbackSnackBar.showError(context, state.message);
              _lastErrorShown = state.message;
            }
          });

          return ListView(
            children: [
              PostPreview(publication: widget.publication),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'Failed to load comments',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            ],
          );
        }

        if (state is CommentsLoaded) {
          if (state.comments.isEmpty) {
            return ListView(
              children: [
                PostPreview(publication: widget.publication),
                const Divider(height: 1, thickness: 1),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: Text(
                      'No comments yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            );
          }
          final commentsToDisplay = state.comments.reversed.toList();
          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: state.comments.length + (state.hasReachedEnd ? 1 : 2),

            separatorBuilder: (context, index) {
              if (index == 0) return const SizedBox.shrink();
              return Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              );
            },

            itemBuilder: (_, index) {
              if (index == 0) {
                return PostPreview(publication: widget.publication);
              }

              final isLoaderIndex = index == state.comments.length + 1;
              if (isLoaderIndex && !state.hasReachedEnd) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final commentIndex = index - 1;

              if (commentIndex >= state.comments.length) {
                return const SizedBox.shrink();
              }

              final comment = commentsToDisplay[commentIndex];
              
               return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  leading: GestureDetector(
                    onTap: () {
                      context.go(Paths.externProfile(comment.userId));
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: comment.profileImageUrl != null
                          ? NetworkImage(comment.profileImageUrl!)
                          : null,
                      child: comment.profileImageUrl == null
                          ? const Icon(Icons.person, size: 22)
                          : null,
                    ),
                  ),
                  title: GestureDetector(
                    onTap: () {
                      context.go(Paths.externProfile(comment.userId));
                    },
                    child: Text(
                      comment.username,
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment.content, style: textTheme.bodyMedium),
                      if (comment.attachmentUrl != null) _buildAttachment(comment.attachmentUrl!),
                    ],
                  ),
                  dense: true,
                );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
