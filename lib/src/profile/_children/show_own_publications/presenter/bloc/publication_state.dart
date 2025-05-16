part of 'publication_bloc.dart';

abstract class PublicationState extends Equatable {
  const PublicationState();

  @override
  List<Object> get props => [];
}

class PublicationInitial extends PublicationState {}

class PublicationLoading extends PublicationState {}

class PublicationFailure extends PublicationState {}

class PublicationSuccess extends PublicationState {
  final List<Publication> publications;
  final bool hasReachedMax;

  const PublicationSuccess({
    required this.publications,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [publications, hasReachedMax];
}
