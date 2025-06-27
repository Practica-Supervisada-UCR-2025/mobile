import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/globals/publications/domain/models/publication.dart';
import 'package:mobile/core/globals/widgets/feedback_snack_bar.dart';
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
      padding: const EdgeInsets.only(top: 8.0, right: 14.0),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CommentsLoadBloc, CommentsLoadState>(
      builder: (context, state) {
        Widget listContent;

        if (state is CommentsLoadInitial ||
            (state is CommentsLoading && state.isInitialFetch)) {
          listContent = Column(
            children: [
              PostPreview(publication: widget.publication),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        } else if (state is CommentsError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_lastErrorShown != state.message) {
              FeedbackSnackBar.showError(context, state.message);
              _lastErrorShown = state.message;
            }
          });

          listContent = ListView(
            children: [
              PostPreview(publication: widget.publication),
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
        } else if (state is CommentsLoaded) {
          final comments = state.comments;

          if (comments.isEmpty) {
            listContent = ListView(
              children: [
                PostPreview(publication: widget.publication),
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
          } else {
            listContent = RefreshIndicator(
              onRefresh: () async {
                context.read<CommentsLoadBloc>().add(FetchInitialComments());
              },
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: comments.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return PostPreview(publication: widget.publication);
                  }

                  if (index <= comments.length) {
                    final comment = comments[index - 1];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 0.3,
                          ),
                        ),
                      ),
                      child: ListTile(
                        titleAlignment: ListTileTitleAlignment.top,
                        contentPadding: const EdgeInsets.only(right: 14.0, top: 8.0, bottom: 8.0),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: comment.profileImageUrl != null
                              ? NetworkImage(comment.profileImageUrl!)
                              : null,
                          child: comment.profileImageUrl == null
                              ? const Icon(Icons.person, size: 22)
                              : null,
                        ),
                        title: Text(
                          comment.username,
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.content, style: textTheme.bodyMedium),
                            if (comment.attachmentUrl != null)
                              _buildAttachment(comment.attachmentUrl!),
                          ],
                        ),
                        dense: true,
                      ),
                    );
                  } else {
                    return state.hasReachedEnd
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: Text('No more comments to show.')),
                          )
                        : const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                  }
                },
              ),
            );
          }
        } else {
          listContent = const SizedBox.shrink();
        }

        return Stack(
          children: [
            Positioned.fill(child: listContent),
          ],
        );
      },
    );
  }
}