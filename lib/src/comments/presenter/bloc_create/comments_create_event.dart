part of 'comments_create_bloc.dart';

abstract class CommentsCreateEvent extends Equatable {
  const CommentsCreateEvent();

  @override
  List<Object?> get props => [];
}

class CommentTextChanged extends CommentsCreateEvent {
  final String text;

  const CommentTextChanged(this.text);

  @override
  List<Object?> get props => [text];
}

class CommentGifChanged extends CommentsCreateEvent {
  final GifModel? gif;

  const CommentGifChanged(this.gif);

  @override
  List<Object?> get props => [gif];
}

class CommentImageChanged extends CommentsCreateEvent {
  final File? image;

  const CommentImageChanged(this.image);

  @override
  List<Object?> get props => [image];
}

class CommentSubmitted extends CommentsCreateEvent {
  final String postId;
  final String? text;
  final File? image;
  final GifModel? selectedGif;

  const CommentSubmitted({
    required this.postId,
    this.text,
    this.image,
    this.selectedGif,
  });

  @override
  List<Object?> get props => [postId, text, image, selectedGif];
}

