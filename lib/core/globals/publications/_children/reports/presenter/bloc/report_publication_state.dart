part of 'report_publication_bloc.dart';

abstract class ReportPublicationState extends Equatable {
  const ReportPublicationState();

  @override
  List<Object?> get props => [];
}

class ReportPublicationInitial extends ReportPublicationState {}

class ReportPublicationLoading extends ReportPublicationState {}

class ReportPublicationSuccess extends ReportPublicationState {}

class ReportPublicationFailure extends ReportPublicationState {
  final String error;

  const ReportPublicationFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class ReportPublicationReset extends ReportPublicationEvent {}
