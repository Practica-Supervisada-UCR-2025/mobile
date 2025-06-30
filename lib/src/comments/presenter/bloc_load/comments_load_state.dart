part of 'comments_load_bloc.dart';

abstract class CommentsLoadState extends Equatable {
  const CommentsLoadState();

  @override
  List<Object?> get props => [];
}

class CommentsLoadInitial extends CommentsLoadState {
  const CommentsLoadInitial();
}

class CommentsLoading extends CommentsLoadState {
  final bool isInitialFetch;

  const CommentsLoading({this.isInitialFetch = false});

  @override
  List<Object?> get props => [isInitialFetch];
}

class CommentsLoaded extends CommentsLoadState {
  final List<CommentModel> comments;
  final bool hasReachedEnd;
  final int currentIndex;
  final DateTime initialFetchTime;

  const CommentsLoaded({
    required this.comments,
    required this.hasReachedEnd,
    required this.currentIndex,
    required this.initialFetchTime,
  });

  CommentsLoaded copyWith({
    List<CommentModel>? comments,
    bool? hasReachedEnd,
    int? currentIndex,
    DateTime? initialFetchTime,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentIndex: currentIndex ?? this.currentIndex,
      initialFetchTime: initialFetchTime?? this.initialFetchTime,
    );
  }

  @override
  List<Object?> get props => [comments, hasReachedEnd, currentIndex];
}

class CommentsError extends CommentsLoadState {
  final String message;

  const CommentsError({required this.message});

  @override
  List<Object?> get props => [message];
}
