import 'package:equatable/equatable.dart';
import 'package:mobile/src/comments/domain/models/comment_model.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

class CommentsLoaded extends CommentsState {
  final List<CommentModel> comments;
  final bool hasReachedEnd;
  final int currentIndex;

  const CommentsLoaded({
    required this.comments,
    required this.hasReachedEnd,
    required this.currentIndex,
  });

  CommentsLoaded copyWith({
    List<CommentModel>? comments,
    bool? hasReachedEnd,
    int? currentIndex,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [comments, hasReachedEnd, currentIndex];
}

class CommentsError extends CommentsState {
  final String message;

  const CommentsError({required this.message});

  @override
  List<Object?> get props => [message];
}
