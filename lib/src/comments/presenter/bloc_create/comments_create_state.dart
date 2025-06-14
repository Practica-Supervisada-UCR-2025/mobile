part of 'comments_create_bloc.dart';

const Object _noValueSentinel = Object();

abstract class CommentsCreateState extends Equatable {
  final String text;
  final File? image;
  final bool isOverLimit;
  final bool isValid;
  final GifModel? selectedGif;

  const CommentsCreateState({
    required this.text,
    required this.image,
    required this.isOverLimit,
    required this.isValid,
    required this.selectedGif,
  });

  @override
  List<Object?> get props => [text, image, isOverLimit, isValid, selectedGif];
}

class CommentsCreateInitial extends CommentsCreateState {
  const CommentsCreateInitial()
      : super(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: false,
          selectedGif: null,
        );

  CommentsCreateState copyWith({
    String? text,
    dynamic image = _noValueSentinel,
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel,
  }) {
    final newImage = image == _noValueSentinel ? this.image : image as File?;
    final newSelectedGif =
        selectedGif == _noValueSentinel ? this.selectedGif : selectedGif as GifModel?;

    if (text == null &&
        image == _noValueSentinel &&
        isOverLimit == null &&
        isValid == null &&
        selectedGif == _noValueSentinel) {
      return this;
    }

    return CommentChanged(
      text: text ?? this.text,
      image: newImage,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid,
      selectedGif: newSelectedGif,
    );
  }
}

class CommentChanged extends CommentsCreateState {
  const CommentChanged({
    required super.text,
    required super.image,
    required super.isOverLimit,
    required super.isValid,
    required super.selectedGif,
  });

  CommentChanged copyWith({
    String? text,
    dynamic image = _noValueSentinel,
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel,
  }) {
    return CommentChanged(
      text: text ?? this.text,
      image: image == _noValueSentinel ? this.image : image as File?,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid,
      selectedGif: selectedGif == _noValueSentinel ? this.selectedGif : selectedGif as GifModel?,
    );
  }
}

class CommentSubmitting extends CommentsCreateState {
  const CommentSubmitting({
    required super.text,
    required super.image,
    required super.isOverLimit,
    required super.isValid,
    required super.selectedGif,
  });

  CommentsCreateState copyWith({
    String? text,
    dynamic image = _noValueSentinel,
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel,
  }) {
    return CommentSubmitting(
      text: text ?? this.text,
      image: image == _noValueSentinel ? this.image : image as File?,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid,
      selectedGif: selectedGif == _noValueSentinel ? this.selectedGif : selectedGif as GifModel?,
    );
  }
}

class CommentSuccess extends CommentsCreateState {
  const CommentSuccess({
    required super.text,
    required super.image,
    required super.isOverLimit,
    required super.isValid,
    required super.selectedGif,
  });

  CommentsCreateState copyWith({
    String? text,
    dynamic image = _noValueSentinel,
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel,
  }) {
    return CommentSuccess(
      text: text ?? this.text,
      image: image == _noValueSentinel ? this.image : image as File?,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid,
      selectedGif: selectedGif == _noValueSentinel ? this.selectedGif : selectedGif as GifModel?,
    );
  }
}

class CommentFailure extends CommentsCreateState {
  final String error;

  const CommentFailure({
    required super.text,
    required super.image,
    required super.isOverLimit,
    required super.isValid,
    required super.selectedGif,
    required this.error,
  });

  @override
  List<Object?> get props => [...super.props, error];

  CommentsCreateState copyWith({
    String? text,
    dynamic image = _noValueSentinel,
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel,
    String? error,
  }) {
    return CommentFailure(
      text: text ?? this.text,
      image: image == _noValueSentinel ? this.image : image as File?,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid,
      selectedGif: selectedGif == _noValueSentinel ? this.selectedGif : selectedGif as GifModel?,
      error: error ?? this.error,
    );
  }
}
