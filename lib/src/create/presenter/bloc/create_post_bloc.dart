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
      final gif = event.gif;

      // Validar que el tamaño no sea mayor a 5MB (5 * 1024 * 1024 bytes)
      if (gif.sizeBytes != null && gif.sizeBytes! > 5 * 1024 * 1024) {
        // No emitir un nuevo estado si el tamaño es inválido
        // log('GIF muy grande: ${gif.sizeBytes} bytes', name: 'CreatePostBloc');
        return;
      }

      emit(state.copyWith(selectedGif: gif));
    });
    on<GifRemoved>((event, emit) {
      emit(state.copyWith(selectedGif: null));
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
