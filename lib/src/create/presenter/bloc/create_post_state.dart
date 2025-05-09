part of 'create_post_bloc.dart';

sealed class CreatePostState extends Equatable {
  final String text;
  final bool isOverLimit;
  final bool isValid;

  const CreatePostState({
    required this.text,
    required this.isOverLimit,
    required this.isValid,
  });

  @override
  List<Object> get props => [text, isOverLimit, isValid];
}

final class CreatePostInitial extends CreatePostState {
  const CreatePostInitial()
      : super(text: '', isOverLimit: false, isValid: false);
}

final class CreatePostChanged extends CreatePostState {
  const CreatePostChanged({
    required super.text,
    required super.isOverLimit,
    required super.isValid,
  });
}
