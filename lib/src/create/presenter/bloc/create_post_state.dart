part of 'create_post_bloc.dart';

sealed class CreatePostState extends Equatable {
  final String text;
  final bool isOverLimit;
  final bool isValid;
  final GifModel? selectedGif;

  const CreatePostState({
    required this.text,
    required this.isOverLimit,
    required this.isValid,
    required this.selectedGif,
  });

  @override
  List<Object?> get props => [text, isOverLimit, isValid, selectedGif];

  CreatePostState copyWith({
    String? text,
    bool? isOverLimit,
    bool? isValid,
    GifModel? selectedGif,
  });
}

final class CreatePostInitial extends CreatePostState {
  const CreatePostInitial()
      : super(
          text: '',
          isOverLimit: false,
          isValid: false,
          selectedGif: null,
        );

  @override
  CreatePostChanged copyWith({
    String? text,
    bool? isOverLimit,
    bool? isValid,
    GifModel? selectedGif,
  }) {
    return CreatePostChanged(
      text: text ?? this.text,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid,
      selectedGif: selectedGif ?? this.selectedGif,
    );
  }
}

final class CreatePostChanged extends CreatePostState {
  const CreatePostChanged({
    required super.text,
    required super.isOverLimit,
    required super.isValid,
    required super.selectedGif,
  });

  @override
  CreatePostChanged copyWith({
    String? text,
    bool? isOverLimit,
    bool? isValid,
    GifModel? selectedGif,
  }) {
    return CreatePostChanged(
      text: text ?? this.text,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid,
      selectedGif: selectedGif ?? this.selectedGif,
    );
  }
}
