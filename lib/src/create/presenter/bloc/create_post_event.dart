part of 'create_post_bloc.dart';

sealed class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object?> get props => [];
}

class PostTextChanged extends CreatePostEvent {
  final String text;

  const PostTextChanged(this.text);

  @override
  List<Object> get props => [text];
}

class PostImageChanged extends CreatePostEvent {
  final File? image;

  const PostImageChanged(this.image);

  @override
  List<Object?> get props => [image];
}

class PostGifChanged extends CreatePostEvent {
  final GifModel? gif;

  const PostGifChanged(this.gif);

  @override
  List<Object?> get props => [gif];
}

class PostSubmitted extends CreatePostEvent {
  final String? text;
  final File? image;
  final GifModel? selectedGif;

  const PostSubmitted({
    this.text,
    this.image,
    this.selectedGif,
  });

  @override
  List<Object?> get props => [text, image, selectedGif];
}