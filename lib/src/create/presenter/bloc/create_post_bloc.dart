import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

part 'create_post_event.dart';
part 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  static const int maxLength = 300;

  CreatePostBloc() : super(const CreatePostInitial()) {
    on<PostTextChanged>(_onTextChanged);
    on<GifSelected>((event, emit) {
      emit(state.copyWith(selectedGif: event.gif));
    });
  }

  void _onTextChanged(PostTextChanged event, Emitter<CreatePostState> emit) {
    final text = event.text;
    final isOverLimit = text.length > maxLength;
    final isValid = text.isNotEmpty && !isOverLimit;

    emit(CreatePostChanged(
      text: text,
      isOverLimit: isOverLimit,
      isValid: isValid,
      selectedGif: state.selectedGif,
    ));
  }
}
