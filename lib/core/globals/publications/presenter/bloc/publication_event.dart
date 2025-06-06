part of 'publication_bloc.dart';

abstract class PublicationEvent extends Equatable {
  const PublicationEvent();

  @override
  List<Object> get props => [];
}

class LoadPublications extends PublicationEvent {}

class LoadMorePublications extends PublicationEvent {}
