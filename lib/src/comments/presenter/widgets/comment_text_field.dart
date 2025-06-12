import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:mobile/core/storage/user_session.storage.dart';
import 'package:mobile/core/theme/app_colors.dart';


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
    final profilePicture = LocalStorage().userProfilePicture;

    return SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: profilePicture.isNotEmpty
                  ? NetworkImage(profilePicture)
                  : null,
              child: profilePicture.isEmpty
                  ? Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onSurface,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: textController,
                focusNode: focusNode,
                onChanged: (text) {
                  context.read<CommentsCreateBloc>().add(CommentTextChanged(text));
                },
                maxLines: null,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Post your reply...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textFieldFillDark
                      : AppColors.textFieldFillLight,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
