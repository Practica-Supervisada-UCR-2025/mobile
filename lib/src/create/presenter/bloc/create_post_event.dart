part of 'create_post_bloc.dart';

sealed class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object> get props => [];
}

class PostTextChanged extends CreatePostEvent {
  final String text;

  const PostTextChanged(this.text);

  @override
  List<Object> get props => [text];
}
