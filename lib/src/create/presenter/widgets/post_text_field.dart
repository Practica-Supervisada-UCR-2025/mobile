import 'package:flutter/material.dart';

class PostTextField extends StatelessWidget {
  final TextEditingController textController;

  const PostTextField({super.key, required this.textController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: textController,
        maxLines: null,
        maxLength: 300,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'What’s on your mind?',
          border: InputBorder.none,
          counterText: '',
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}