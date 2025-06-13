import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/globals/publications/domain/models/publication.dart';
import 'package:mobile/src/comments/comments.dart';

class CommentsList extends StatefulWidget {
  final Publication publication;
  const CommentsList({super.key, required this.publication});

  @override
  State<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList> {
  late final ScrollController _scrollController;

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CommentsLoadBloc, CommentsLoadState>(
      builder: (context, state) {
        if (state is CommentsLoadInitial || (state is CommentsLoading && state.isInitialFetch)) {
          return Column(
            children: [
              PostPreview(publication: widget.publication),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        if (state is CommentsError) {
          return Column(
            children: [
              PostPreview(publication: widget.publication),
              Expanded(
                child: Center(child: Text('Error: ${state.message}')),
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
                      'Aún no hay comentarios',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            );
          }

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

              if(commentIndex >= state.comments.length) {
                return const SizedBox.shrink(); 
              }

              final comment = state.comments[commentIndex];
              
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0), 
                leading: const CircleAvatar(radius: 20), 
                title: Text(comment.username, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(comment.content, style: textTheme.bodyMedium),
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
