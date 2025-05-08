import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';

class TopActions extends StatelessWidget {
  const TopActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();

            Future.delayed(Duration(milliseconds: 150), () {
              if (context.mounted) {
                context.pop();
              }
            });
            
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // Action to post the content
          },
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Post',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        )
      ],
    );
  }
}