import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:equatable/equatable.dart';

part 'comments_load_event.dart';
part 'comments_load_state.dart';

class CommentsLoadBloc extends Bloc<CommentsLoadEvent, CommentsLoadState> {
  final CommentsRepository repository;
  final String postId;
  static const int _commentsPerPage = 5;


  CommentsLoadBloc({
    required this.repository,
    required this.postId,
  }) : super(const CommentsLoadInitial()) {
    on<FetchInitialComments>(_onFetchInitialComments);
    on<FetchMoreComments>(_onFetchMoreComments);
  }

  Future<void> _onFetchInitialComments(
    FetchInitialComments event,
    Emitter<CommentsLoadState> emit,
  ) async {
    emit(const CommentsLoading(isInitialFetch: true));
    try {
      final fetchTime = DateTime.fromMillisecondsSinceEpoch(0);
      final response = await repository.fetchComments(
        postId: postId,
        startTime: fetchTime,
        limit: _commentsPerPage,
        index: 0,
      );
      emit(CommentsLoaded(
        comments: response.comments,
        hasReachedEnd: response.comments.length >= response.totalItems
        || response.comments.isEmpty,
        currentIndex: response.currentIndex,
        initialFetchTime: fetchTime,
      ));
    } catch (e) {
      emit(CommentsError(message: e.toString()));
    }
  }

  Future<void> _onFetchMoreComments(
    FetchMoreComments event,
    Emitter<CommentsLoadState> emit,
  ) async {
    if (state is! CommentsLoaded || (state as CommentsLoaded).hasReachedEnd) return;

    final currentState = state as CommentsLoaded;

    try {
      final startTime = currentState.initialFetchTime;
      final nextIndex = currentState.currentIndex + 1;
      final response = await repository.fetchComments(
        postId: postId,
        startTime: startTime,
        limit: _commentsPerPage,
        index: nextIndex,
      );

      if (response.comments.isEmpty) {
        emit(currentState.copyWith(hasReachedEnd: true));
        return;
      }
      
      final updatedComments = List<CommentModel>.from(currentState.comments)
        ..addAll(response.comments);


      emit(currentState.copyWith(
        comments: updatedComments,
        hasReachedEnd: updatedComments.length >= response.totalItems,
        currentIndex: response.currentIndex,
      ));
    } catch (e) {
      emit(CommentsError(message: e.toString()));
    }
  }
}
