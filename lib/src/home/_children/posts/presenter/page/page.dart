import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: const Center(
        child: Text(
          'No posts available',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}