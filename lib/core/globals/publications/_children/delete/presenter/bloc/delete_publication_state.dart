part of 'delete_publication_bloc.dart';

abstract class DeletePublicationState extends Equatable {
  const DeletePublicationState();

  @override
  List<Object?> get props => [];
}

class DeletePublicationInitial extends DeletePublicationState {}

class DeletePublicationLoading extends DeletePublicationState {}

class DeletePublicationSuccess extends DeletePublicationState {}

class DeletePublicationFailure extends DeletePublicationState {
  final String error;

  const DeletePublicationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
