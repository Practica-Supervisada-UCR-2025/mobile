import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/comments/domain/repository/comments_repository.dart';
import 'package:mobile/src/comments/presenter/bloc/comments_event.dart';
import 'package:mobile/src/comments/presenter/bloc/comments_state.dart';
import 'package:mobile/src/comments/domain/models/comment_model.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final CommentsRepository repository;
  final String postId;

  CommentsBloc({
    required this.repository,
    required this.postId,
  }) : super(const CommentsInitial()) {
    on<FetchInitialComments>(_onFetchInitialComments);
    on<FetchMoreComments>(_onFetchMoreComments);
  }

  Future<void> _onFetchInitialComments(
    FetchInitialComments event,
    Emitter<CommentsState> emit,
  ) async {
    emit(const CommentsLoading());
    try {
      final response = await repository.fetchComments(postId: postId, 
      startTime: DateTime.fromMillisecondsSinceEpoch(0),);
      emit(CommentsLoaded(
        comments: response.comments,
        hasReachedEnd: response.comments.length >= response.totalItems,
        currentIndex: response.currentIndex,
      ));
    } catch (e) {
      emit(CommentsError(message: e.toString()));
    }
  }

  Future<void> _onFetchMoreComments(
    FetchMoreComments event,
    Emitter<CommentsState> emit,
  ) async {
    if (state is! CommentsLoaded || (state as CommentsLoaded).hasReachedEnd) return;

    final currentState = state as CommentsLoaded;

    try {
      final response = await repository.fetchComments(
        postId: postId,
        startTime: currentState.comments.last.createdAt,
      );


      final updatedComments = List<CommentModel>.from(currentState.comments)..addAll(response.comments);

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
