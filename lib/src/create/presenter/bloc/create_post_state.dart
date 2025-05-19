part of 'create_post_bloc.dart';

// Objeto centinela para el método copyWith.
// Se usa para diferenciar cuando un argumento no se pasa en absoluto
// de cuando un argumento se pasa explícitamente como null.
const Object _noValueSentinel = Object();

sealed class CreatePostState extends Equatable {
  final String text;
  final bool isOverLimit;
  final bool isValid;
  final GifModel? selectedGif;

  const CreatePostState({
    required this.text,
    required this.isOverLimit,
    required this.isValid,
    required this.selectedGif,
  });

  @override
  List<Object?> get props => [text, isOverLimit, isValid, selectedGif];

  // Declaración del método copyWith. Las implementaciones están en las subclases.
  CreatePostState copyWith({
    String? text,
    bool? isOverLimit,
    bool? isValid,
    // Usamos 'dynamic' aquí para permitir el centinela.
    // El tipo real se manejará en la implementación.
    dynamic selectedGif = _noValueSentinel,
  });
}

final class CreatePostInitial extends CreatePostState {
  const CreatePostInitial()
      : super(
          text: '',
          isOverLimit: false,
          isValid: false,
          selectedGif: null,
        );

  @override
  CreatePostState copyWith({ // Debería devolver CreatePostState o CreatePostInitial
    String? text,
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel,
  }) {
    // Si CreatePostInitial.copyWith siempre debe transicionar a CreatePostChanged,
    // entonces la implementación actual es una forma de hacerlo.
    // Sin embargo, típicamente copyWith devuelve una instancia del mismo tipo.
    // Si la intención es que CreatePostInitial no cambie o solo cambie a CreatePostChanged
    // con todos los campos, entonces la lógica actual de tu BLoC que crea
    // instancias de CreatePostChanged directamente es más clara.

    // Para que este copyWith sea más "correcto" en el sentido de que podría
    // devolver un CreatePostInitial si solo se cambian campos compatibles:
    final newSelectedGif = selectedGif == _noValueSentinel
        ? this.selectedGif // que es null para CreatePostInitial
        : selectedGif as GifModel?;

    // Si el estado después de copyWith sigue siendo "inicial" (ej. texto vacío, sin gif)
    // podrías devolver un `const CreatePostInitial()`. De lo contrario, un `CreatePostChanged`.
    // Por simplicidad y dado que tu BLoC maneja las transiciones de estado explícitamente,
    // podríamos hacer que este copyWith se comporte de forma más estándar:
    if ( (text == null || text.isEmpty) &&
         (isOverLimit == null || !isOverLimit) &&
         (isValid == null || !isValid) &&
         (newSelectedGif == null) ) {
        // Si todos los valores resultantes son los iniciales, devuelve CreatePostInitial
        // (esto es una simplificación, la lógica de isValid es más compleja)
        // Para mantenerlo simple, si se llama a copyWith en Initial y no se provee nada,
        // devuelve el mismo estado inicial.
        if (text == null && isOverLimit == null && isValid == null && selectedGif == _noValueSentinel) {
            return this;
        }
    }
    
    // Si se especifica algo, transiciona a CreatePostChanged (como lo hacía antes)
    return CreatePostChanged(
      text: text ?? this.text,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid, // La validez real se recalculará en el BLoC
      selectedGif: newSelectedGif,
    );
  }
}

final class CreatePostChanged extends CreatePostState {
  const CreatePostChanged({
    required super.text,
    required super.isOverLimit,
    required super.isValid,
    required super.selectedGif,
  });

  @override
  CreatePostChanged copyWith({
    String? text,
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel, // Usar el centinela
  }) {
    return CreatePostChanged(
      text: text ?? this.text,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid, // La validez real se recalculará en el BLoC
                                      // si el texto cambia a través de un evento.
      // Lógica corregida para selectedGif:
      // Si selectedGif es el centinela, significa que el argumento no se pasó,
      // así que mantenemos el valor actual (this.selectedGif).
      // De lo contrario, usamos el valor que se pasó (que podría ser un GifModel o null).
      selectedGif: selectedGif == _noValueSentinel
          ? this.selectedGif
          : selectedGif as GifModel?,
    );
  }
}
