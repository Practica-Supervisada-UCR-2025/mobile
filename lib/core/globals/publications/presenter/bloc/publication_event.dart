part of 'publication_bloc.dart';

abstract class PublicationEvent extends Equatable {
  const PublicationEvent();

  @override
  List<Object> get props => [];
}

class LoadPublications extends PublicationEvent {
  final bool isFeed;

  const LoadPublications({this.isFeed = false});

  @override
  List<Object> get props => [isFeed];
}

class LoadMorePublications extends PublicationEvent {
  final bool isFeed;

  const LoadMorePublications({this.isFeed = false});

  @override
  List<Object> get props => [isFeed];
}

class RefreshPublications extends PublicationEvent {
  final bool isFeed;

  const RefreshPublications({this.isFeed = false});

  @override
  List<Object> get props => [isFeed];
}

class HidePublication extends PublicationEvent {
  final String publicationId;

  const HidePublication(this.publicationId);

  @override
  List<Object> get props => [publicationId];
}
