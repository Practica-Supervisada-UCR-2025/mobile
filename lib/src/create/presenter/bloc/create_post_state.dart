part of 'create_post_bloc.dart';

// Objeto centinela para el método copyWith.
// Se usa para diferenciar cuando un argumento no se pasa en absoluto
// de cuando un argumento se pasa explícitamente como null.
const Object _noValueSentinel = Object();

sealed class CreatePostState extends Equatable {
  final String text;
  final File? image; // Campo de la rama 'develop'
  final bool isOverLimit;
  final bool isValid;
  final GifModel? selectedGif; // Campo de la rama 'HEAD'

  const CreatePostState({
    required this.text,
    required this.image, // Añadido al constructor
    required this.isOverLimit,
    required this.isValid,
    required this.selectedGif, // Añadido al constructor
  });

  @override
  // Combinamos los props de ambas ramas
  List<Object?> get props => [text, image, isOverLimit, isValid, selectedGif];

  // Declaración del método copyWith combinada.
  // Las implementaciones están en las subclases.
  CreatePostState copyWith({
    String? text,
    dynamic image = _noValueSentinel, // Añadido para el campo image
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel, // Mantenido de HEAD
  });
}

final class CreatePostInitial extends CreatePostState {
  const CreatePostInitial()
      : super(
          text: '',
          image: null, // Valor inicial para image
          isOverLimit: false,
          isValid: false,
          selectedGif: null, // Valor inicial para selectedGif
        );

  @override
  CreatePostState copyWith({
    String? text,
    dynamic image = _noValueSentinel, // Añadido para el campo image
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel, // Mantenido de HEAD
  }) {
    final newImage = image == _noValueSentinel
        ? this.image // que es null para CreatePostInitial
        : image as File?;

    final newSelectedGif = selectedGif == _noValueSentinel
        ? this.selectedGif // que es null para CreatePostInitial
        : selectedGif as GifModel?;

    // Si después de aplicar los cambios, el estado sigue siendo "inicial"
    // (ej. texto vacío, sin imagen, sin gif), podríamos devolver `this` o `const CreatePostInitial()`.
    // Sin embargo, la lógica de tu BLoC parece crear instancias de `CreatePostChanged`
    // cuando hay cualquier modificación sustancial, lo cual es una estrategia válida.

    // Si no se proporciona ningún argumento, devuelve la instancia actual (o una nueva idéntica).
    if (text == null &&
        image == _noValueSentinel &&
        isOverLimit == null &&
        isValid == null && // La validez real se recalcula en el BLoC
        selectedGif == _noValueSentinel) {
      // Podrías devolver 'this' si CreatePostInitial fuera inmutable y 'const'.
      // Devolver una nueva instancia con los mismos valores es más seguro si no es 'const'.
      // O, si la intención es siempre transicionar a CreatePostChanged, entonces la lógica de abajo está bien.
      // Por ahora, si no hay cambios, devolvemos el mismo estado.
      return this;
    }
    
    // Si se especifica algún cambio, transiciona a CreatePostChanged.
    return CreatePostChanged(
      text: text ?? this.text,
      image: newImage, // Usar el newImage resuelto
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid, // La validez real se recalculará en el BLoC
      selectedGif: newSelectedGif, // Usar el newSelectedGif resuelto
    );
  }
}

final class CreatePostChanged extends CreatePostState {
  const CreatePostChanged({
    required super.text,
    required super.image, // Campo de la rama 'develop'
    required super.isOverLimit,
    required super.isValid,
    required super.selectedGif, // Campo de la rama 'HEAD'
  });

  @override
  CreatePostChanged copyWith({
    String? text,
    dynamic image = _noValueSentinel, // Añadido para el campo image
    bool? isOverLimit,
    bool? isValid,
    dynamic selectedGif = _noValueSentinel, // Mantenido de HEAD
  }) {
    return CreatePostChanged(
      text: text ?? this.text,
      // Lógica con centinela para image
      image: image == _noValueSentinel
          ? this.image
          : image as File?,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isValid: isValid ?? this.isValid, // La validez real se recalculará en el BLoC
                                      // si el texto o la imagen cambian a través de un evento.
      // Lógica con centinela para selectedGif
      selectedGif: selectedGif == _noValueSentinel
          ? this.selectedGif
          : selectedGif as GifModel?,
    );
  }
}