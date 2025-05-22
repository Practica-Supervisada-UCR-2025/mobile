part of 'create_post_bloc.dart';

const Object _noValueSentinel = Object();

sealed class CreatePostState extends Equatable {
  final String text;
  final File? image;
  final bool isOverLimit;
  final bool isValid;
  final GifModel? selectedGif;

  const CreatePostState({
    required this.text,
    required this.image, 
    required this.isOverLimit,
    required this.isValid,
    required this.selectedGif, 
  });

  @override
  List<Object?> get props => [text, image, isOverLimit, isValid, selectedGif];

  CreatePostState copyWith({
    String? text,
    dynamic image = _noValueSentinel, 
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel,
  });
}

final class CreatePostInitial extends CreatePostState {
  const CreatePostInitial()
      : super(
          text: '',
          image: null, 
          isOverLimit: false,
          isValid: false,
          selectedGif: null, 
        );

  @override
  CreatePostState copyWith({
    String? text,
    dynamic image = _noValueSentinel,
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel, 
  }) {
    final newImage = image == _noValueSentinel
        ? this.image
        : image as File?;

    final newSelectedGif = selectedGif == _noValueSentinel
        ? this.selectedGif 
        : selectedGif as GifModel?;

    if (text == null &&
        image == _noValueSentinel &&
        isOverLimit == null &&
        isValid == null &&
        selectedGif == _noValueSentinel) {
      return this;
    }
    
    return CreatePostChanged(
      text: text ?? this.text,
      image: newImage, 
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid, 
      selectedGif: newSelectedGif,
    );
  }
}

final class CreatePostChanged extends CreatePostState {
  const CreatePostChanged({
    required super.text,
    required super.image, 
    required super.isOverLimit,
    required super.isValid,
    required super.selectedGif,
  });

  @override
  CreatePostChanged copyWith({
    String? text,
    dynamic image = _noValueSentinel,
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel, 
  }) {
    return CreatePostChanged(
      text: text ?? this.text,
      image: image == _noValueSentinel
          ? this.image
          : image as File?,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid, 
      selectedGif: selectedGif == _noValueSentinel
          ? this.selectedGif
          : selectedGif as GifModel?,
    );
  }
}