import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/comments/comments.dart';


class CommentInputBox extends StatelessWidget {
  final TextEditingController textController;

  const CommentInputBox({super.key, required this.textController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: textController,
        onChanged: (text) {
          context.read<CommentsCreateBloc>().add(CommentTextChanged(text));
        },
        maxLines: null,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Post your reply...',
          border: InputBorder.none,
          counterText: '',
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
