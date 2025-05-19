import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/create/create.dart'; // Asegúrate que la ruta sea correcta

class PostTextField extends StatelessWidget {
  final TextEditingController textController;

  const PostTextField({super.key, required this.textController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreatePostBloc, CreatePostState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisSize: MainAxisSize.min, // Puede ser útil si esta Columna está dentro de otra que permite scroll
            children: [
              TextField(
                controller: textController,
                onChanged: (text) {
                  context.read<CreatePostBloc>().add(PostTextChanged(text));
                },
                maxLines: null, // Permite múltiples líneas
                minLines: 3,   // Unas pocas líneas para que parezca un área de texto
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'What’s on your mind?',
                  border: InputBorder.none,
                  counterText: '',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                // Considera añadir maxLength aquí también si quieres el feedback visual del TextField
                // maxLength: CreatePostBloc.maxLength,
              ),
              const SizedBox(height: 12),
              if (state.selectedGif != null)
                // Contenedor para el GIF con restricciones de tamaño
                SizedBox(
                  // Ancho: que ocupe lo disponible en la columna (respetando el padding del padre).
                  // La columna por defecto intentará ser tan ancha como sus hijos o su padre.
                  // No es necesario un width: double.infinity aquí si la Columna padre ya está restringida.
                  // Altura: define una altura máxima para la vista previa del GIF.
                  height: 200, // <-- AJUSTA ESTA ALTURA MÁXIMA COMO CONSIDERES
                  width: double.infinity, // Para que ocupe el ancho disponible y centre la imagen si es más angosta
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      // Centrar la imagen dentro del SizedBox si es más pequeña que el SizedBox
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            state.selectedGif!.tinyGifUrl,
                            // BoxFit.contain asegura que toda la imagen sea visible
                            // y mantenga su relación de aspecto dentro de los límites
                            // del widget padre (en este caso, el Center/SizedBox).
                            fit: BoxFit.contain,
                            // Es bueno añadir constructores de carga y error
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              return Container(
                                color: Colors.grey[200], // Fondo para el error
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            debugPrint('❌ Eliminando GIF');
                            context.read<CreatePostBloc>().add(GifRemoved());
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54, // Un poco más opaco
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(5), // Ajuste de padding
                            child: const Icon(
                              Icons.close,
                              size: 16, // Tamaño del icono
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}