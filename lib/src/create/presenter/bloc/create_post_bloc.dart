import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'create_post_event.dart';
part 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  static const int maxLength = 300;

  CreatePostBloc() : super(const CreatePostInitial()) {
    on<PostTextChanged>(_onTextChanged);
    on<PostImageChanged>(_onImageChanged);
  }
  void _onTextChanged(PostTextChanged event, Emitter<CreatePostState> emit) {
    final text = event.text;
    final isOverLimit = text.length > maxLength;
    final isValid = (text.isNotEmpty && !isOverLimit) || state.image != null;

    emit(CreatePostChanged(
      text: text,
      image: state.image,
      isOverLimit: isOverLimit,
      isValid: isValid,
    ));
  }

  void _onImageChanged(PostImageChanged event, Emitter<CreatePostState> emit) {
    final image = event.image;
     
    final isValid = image != null || (state.text.isNotEmpty && !state.isOverLimit);
    
    emit(CreatePostChanged(
      text: state.text,
      image: image,
      isOverLimit: state.isOverLimit,
      isValid: isValid,
    ));
  }
}
