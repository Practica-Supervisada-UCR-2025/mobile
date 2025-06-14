import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mobile/src/comments/domain/repository/comments_repository.dart';

part 'comments_create_event.dart';
part 'comments_create_state.dart';

class CommentsCreateBloc extends Bloc<CommentsCreateEvent, CommentsCreateState> {
  static const int maxLength = 300;
  final CommentsRepository? commentsRepository;

  CommentsCreateBloc({required this.commentsRepository}) : super(const CommentChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: false,
          selectedGif: null)) {
    on<CommentTextChanged>(_onCommentTextChanged);
    on<CommentImageChanged>(_onCommentImageChanged);
    on<CommentGifChanged>(_onCommentGifChanged);
    on<CommentSubmitted>(_onCommentSubmitted);
  }

  void _onCommentTextChanged(CommentTextChanged event, Emitter<CommentsCreateState> emit) {
    final text = event.text;
    final isOverLimit = text.runes.length > maxLength;
    final isValid = !isOverLimit && (text.isNotEmpty || state.image != null || state.selectedGif != null);

    emit(CommentChanged(
      text: text,
      image: state.image,
      isOverLimit: isOverLimit,
      isValid: isValid,
      selectedGif: state.selectedGif,
    ));
  }

  void _onCommentImageChanged(CommentImageChanged event, Emitter<CommentsCreateState> emit) {
    final newImage = event.image;
    final newSelectedGif = null;

    final currentText = state.text;
    final isOverLimit = state.isOverLimit;

    final isValid = !isOverLimit && (currentText.isNotEmpty || newImage != null || newSelectedGif != null);

    emit(CommentChanged(
      text: currentText,
      image: newImage,
      isOverLimit: isOverLimit,
      isValid: isValid,
      selectedGif: newSelectedGif,
    ));
  }

  void _onCommentGifChanged(CommentGifChanged event, Emitter<CommentsCreateState> emit) {
    final newSelectedGif = event.gif;

    if (newSelectedGif != null && newSelectedGif.sizeBytes != null && newSelectedGif.sizeBytes! > 5 * 1024 * 1024) {
      return;
    }

    final newImage = null;
    final currentText = state.text;
    final isOverLimit = state.isOverLimit;

    final isValid = !isOverLimit && (currentText.isNotEmpty || newImage != null || newSelectedGif != null);

    emit(CommentChanged(
      text: currentText,
      image: newImage,
      isOverLimit: isOverLimit,
      isValid: isValid,
      selectedGif: newSelectedGif,
    ));
  }

  Future<void> _onCommentSubmitted(
    CommentSubmitted event,
    Emitter<CommentsCreateState> emit,
  ) async {
    final textToSubmit = event.text ?? state.text;
    final imageToSubmit = event.image ?? state.image;
    final gifToSubmit = event.selectedGif ?? state.selectedGif;

    emit(CommentSubmitting(
      text: textToSubmit,
      image: imageToSubmit,
      isOverLimit: state.isOverLimit,
      isValid: state.isValid,
      selectedGif: gifToSubmit,
    ));

    try {
      await commentsRepository!.sendComment(
        postId: event.postId,
        text: textToSubmit,
        image: imageToSubmit,
        selectedGif: gifToSubmit,
      );

      emit(CommentSuccess(
        text: textToSubmit,
        image: imageToSubmit,
        isOverLimit: state.isOverLimit,
        isValid: state.isValid,
        selectedGif: gifToSubmit,
      ));
    } catch (e) {
      emit(CommentFailure(
        text: textToSubmit,
        image: imageToSubmit,
        isOverLimit: state.isOverLimit,
        isValid: state.isValid,
        selectedGif: gifToSubmit,
        error: e.toString(),
      ));
    }
  }
}
