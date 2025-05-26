import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/profile/profile.dart';

class DeletePublicationDialog extends StatelessWidget {
  final String publicationId;

  const DeletePublicationDialog({
    super.key,
    required this.publicationId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text(
            "Are you sure?",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: const Text(
        "Do you really want to delete this post? You will not be able to undo this action.",
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            PrimaryButton(
              onPressed: () {
                context.read<PublicationBloc>().add(DeletePublicationRequested(publicationId));
                Navigator.of(context).pop();
              },
              text: "Delete",
              isLoading: false,
              isEnabled: true,
            ),
          ],
        ),
      ],
    );
  }
}
