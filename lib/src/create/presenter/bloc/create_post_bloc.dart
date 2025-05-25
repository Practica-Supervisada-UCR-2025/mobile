import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/src/create/domain/repository/create_post.repository.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

part 'create_post_event.dart';
part 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  static const int maxLength = 300;
  final CreatePostRepository? createPostRepository;

  CreatePostBloc({required this.createPostRepository}) : super(const CreatePostInitial()) {
    on<PostTextChanged>(_onTextChanged);
    on<PostImageChanged>(_onImageChanged);
    on<PostGifChanged>(_onGifChanged);
    on<PostSubmitted>(_onPostSubmitted);
  }

  void _onTextChanged(PostTextChanged event, Emitter<CreatePostState> emit) {
    final text = event.text;
    final isOverLimit = text.runes.length > maxLength;
    final isValid = !isOverLimit && (text.isNotEmpty || state.image != null || state.selectedGif != null);

    emit(CreatePostChanged(
      text: text,
      image: state.image, 
      isOverLimit: isOverLimit,
      isValid: isValid,
      selectedGif: state.selectedGif, 
    ));
  }

  void _onImageChanged(PostImageChanged event, Emitter<CreatePostState> emit) {
    final newImage = event.image;
    final newSelectedGif = null; 

    final currentText = state.text;
    final isOverLimit = state.isOverLimit;

    final isValid = !isOverLimit && (currentText.isNotEmpty || newImage != null || newSelectedGif != null);

    emit(CreatePostChanged(
      text: currentText,
      image: newImage,
      isOverLimit: isOverLimit,
      isValid: isValid,
      selectedGif: newSelectedGif,
    ));
  }

  void _onGifChanged(PostGifChanged event, Emitter<CreatePostState> emit) {
    final newSelectedGif = event.gif;

    if (newSelectedGif != null && newSelectedGif.sizeBytes != null && newSelectedGif.sizeBytes! > 5 * 1024 * 1024) {
      return; 
    }

    final newImage = null; 
    final currentText = state.text; 
    final isOverLimit = state.isOverLimit; 

    final isValid = !isOverLimit && (currentText.isNotEmpty || newImage != null || newSelectedGif != null);

    emit(CreatePostChanged(
      text: currentText,
      image: newImage,
      isOverLimit: isOverLimit,
      isValid: isValid,
      selectedGif: newSelectedGif,
    ));
  }

  Future<void> _onPostSubmitted(
    PostSubmitted event, 
    Emitter<CreatePostState> emit,
  ) async { 
    emit(PostSubmitting(
      text: state.text,
      image: state.image,
      isOverLimit: state.isOverLimit,
      isValid: state.isValid,
      selectedGif: state.selectedGif,
    ));

    try {
      final textToSubmit = event.text ?? state.text;
      final imageToSubmit = event.image ?? state.image;
      final gifToSubmit = event.selectedGif ?? state.selectedGif;

      await createPostRepository!.createPost(
        text: textToSubmit,
        image: imageToSubmit,
        selectedGif: gifToSubmit,
      );

      emit(PostSubmitSuccess(
        text: state.text,
        image: state.image,
        isOverLimit: state.isOverLimit,
        isValid: state.isValid,
        selectedGif: state.selectedGif,
      ));
    } catch (e) {
      emit(PostSubmitFailure(
        text: state.text,
        image: state.image,
        isOverLimit: state.isOverLimit,
        isValid: state.isValid,
        selectedGif: state.selectedGif,
        error: e.toString(),
      ));
    }
  }
}