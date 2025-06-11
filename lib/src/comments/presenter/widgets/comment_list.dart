import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/globals/publications/domain/models/publication.dart';
import 'package:mobile/src/comments/presenter/bloc/comments_bloc.dart';
import 'package:mobile/src/comments/presenter/bloc/comments_event.dart';
import 'package:mobile/src/comments/presenter/bloc/comments_state.dart';
import 'package:mobile/src/comments/presenter/page/comments_page.dart';

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
      context.read<CommentsBloc>().add(FetchMoreComments());
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

    return BlocBuilder<CommentsBloc, CommentsState>(
      builder: (context, state) {
        if (state is CommentsInitial || (state is CommentsLoading && state.isInitialFetch)) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is CommentsLoaded) {
          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: state.hasReachedEnd
                ? state.comments.length + 1 
                : state.comments.length + 2,
            
            separatorBuilder: (context, index) {
              if (index < state.comments.length) { 
                return Divider(
                  height: 1, 
                  thickness: 1, 
                  indent: 16,
                  endIndent: 16,
                );
              }
              return const SizedBox.shrink(); 
            },
            
            itemBuilder: (_, index) {
              if (index == 0) {
                return PostPreview(publication: widget.publication);
              }

              if (index >= state.comments.length + 1) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final commentIndex = index - 1;
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
        
        if (state is CommentsError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}