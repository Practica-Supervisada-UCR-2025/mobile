import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/comments/comments.dart';


class CommentTextField extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;

  const CommentTextField({
    super.key,
    required this.textController,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: TextField(
          controller: textController,
          focusNode: focusNode,
          onChanged: (text) {
            context.read<CommentsCreateBloc>().add(CommentTextChanged(text));
          },
          maxLines: null,
          autofocus: false,
          decoration: const InputDecoration(
            hintText: 'Post your reply...',
            border: InputBorder.none,
            counterText: '',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
