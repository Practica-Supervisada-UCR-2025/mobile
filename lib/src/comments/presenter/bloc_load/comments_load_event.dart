part of 'comments_load_bloc.dart';

sealed class CommentsLoadEvent extends Equatable {
  const CommentsLoadEvent();

  @override
  List<Object?> get props => [];
}

class FetchInitialComments extends CommentsLoadEvent {}

class FetchMoreComments extends CommentsLoadEvent {}
