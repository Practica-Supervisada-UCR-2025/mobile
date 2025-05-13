import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Shimmer.fromColors(
                baseColor: color,
                highlightColor: Theme.of(context).colorScheme.onPrimary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlaceholder(height: 24, width: 180, context: context), 
                    const SizedBox(height: 8),
                    _buildPlaceholder(height: 18, width: 120, context: context),
                    const SizedBox(height: 8),
                    _buildPlaceholder(height: 16, width: 220, context: context),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildButtonPlaceholder(context: context)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildButtonPlaceholder(context: context)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Shimmer.fromColors(
              baseColor: color,
              highlightColor: Theme.of(context).colorScheme.outline,
              child: SizedBox(
                width: 70,
                height: 70,
                child: CircleAvatar(
                  backgroundColor: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Divider(color: Theme.of(context).colorScheme.outline),
      ],
    );
  }

  Widget _buildPlaceholder({required double height, required double width, required BuildContext context}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildButtonPlaceholder({required BuildContext context}) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
