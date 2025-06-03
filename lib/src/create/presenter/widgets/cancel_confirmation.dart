import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CancelConfirmation extends StatelessWidget {
  const CancelConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 85, 85, 85)
        : const Color.fromARGB(255, 207, 207, 207);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 280, // Slightly narrower width
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Discard this post?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'If you discard now, all your changes will be lost.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: dividerColor),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  context.pop(); // Close the modal
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (context.mounted) {
                      context.pop(); // Navigate back
                    }
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  alignment: Alignment.center,
                ),
                child: const Text(
                  'Discard post',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            Divider(height: 1, color: dividerColor),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the modal
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  alignment: Alignment.center,
                ),
                child: const Text(
                  'Keep editing',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}