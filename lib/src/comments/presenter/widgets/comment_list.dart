import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/comments/presenter/bloc/comments_bloc.dart';
import 'package:mobile/src/comments/presenter/bloc/comments_event.dart';
import 'package:mobile/src/comments/presenter/bloc/comments_state.dart';

class CommentsList extends StatefulWidget {
  final String postId;
  const CommentsList({super.key, required this.postId});

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

    context.read<CommentsBloc>().add(FetchInitialComments());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      context.read<CommentsBloc>().add(FetchMoreComments());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CommentsBloc, CommentsState>(
      builder: (context, state) {
        if (state is CommentsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CommentsLoaded) {
          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.comments.length + (state.hasReachedEnd ? 0 : 1),
            separatorBuilder: (_, __) => Divider(height: 1, color: colorScheme.outline),
            itemBuilder: (_, index) {
              if (index >= state.comments.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final comment = state.comments[index];
              return Container(
                color: colorScheme.surface,
                child: ListTile(
                  leading: const CircleAvatar(),
                  title: Text(comment.username, style: textTheme.bodyMedium),
                  subtitle: Text(
                    comment.content,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                  ),
                ),
              );
            },
          );
        } else if (state is CommentsError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const SizedBox();
        }
      },
    );
  }
}