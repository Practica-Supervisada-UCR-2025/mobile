part of 'delete_publication_bloc.dart';

abstract class DeletePublicationEvent extends Equatable {
  const DeletePublicationEvent();

  @override
  List<Object?> get props => [];
}

class DeletePublicationRequest extends DeletePublicationEvent {
  final String publicationId;

  const DeletePublicationRequest({required this.publicationId});

  @override
  List<Object?> get props => [publicationId];
}

class DeletePublicationReset extends DeletePublicationEvent {}
