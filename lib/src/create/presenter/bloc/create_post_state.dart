part of 'create_post_bloc.dart';

sealed class CreatePostState extends Equatable {
  final String text;
  final File? image;
  final bool isOverLimit;
  final bool isValid;

  const CreatePostState({
    required this.text,
    required this.image,
    required this.isOverLimit,
    required this.isValid,
  });

  @override
  List<Object?> get props => [text, image, isOverLimit, isValid];
}

final class CreatePostInitial extends CreatePostState {
  const CreatePostInitial()
      : super(text: '', image: null, isOverLimit: false, isValid: false);
}

final class CreatePostChanged extends CreatePostState {
  const CreatePostChanged({
    required super.text,
    required super.image,
    required super.isOverLimit,
    required super.isValid
  });
}
