import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/create/create.dart';

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
            children: [
              TextField(
                controller: textController,
                onChanged: (text) {
                  context.read<CreatePostBloc>().add(PostTextChanged(text));
                },
                maxLines: null,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'What’s on your mind?',
                  border: InputBorder.none,
                  counterText: '',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              if (state.selectedGif != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    state.selectedGif!.tinyGifUrl,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
