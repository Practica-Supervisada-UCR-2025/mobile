part of 'publication_bloc.dart';

abstract class PublicationEvent extends Equatable {
  const PublicationEvent();

  @override
  List<Object> get props => [];
}

class LoadPublications extends PublicationEvent {
  final bool isFeed;
  final bool isOtherUser;
  const LoadPublications({this.isFeed = false, this.isOtherUser = false});

  @override
  List<Object> get props => [isFeed];
}

class LoadMorePublications extends PublicationEvent {
  final bool isFeed;
  final bool isOtherUser;

  const LoadMorePublications({this.isFeed = false, this.isOtherUser = false});

  @override
  List<Object> get props => [isFeed];
}

class RefreshPublications extends PublicationEvent {
  final bool isFeed;
  final bool isOtherUser;
  
  const RefreshPublications({this.isFeed = false, this.isOtherUser = false});

  @override
  List<Object> get props => [isFeed];
}
