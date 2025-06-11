import 'package:equatable/equatable.dart';

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

class FetchInitialComments extends CommentsEvent {}

class FetchMoreComments extends CommentsEvent {}
